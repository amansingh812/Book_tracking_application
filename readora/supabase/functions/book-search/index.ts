// book-search
//
// POST { q?: string, isbn?: string, limit?: number }
// -> { books: BookDto[] }
//
// Google Books is the primary source (best title/author search and covers).
// Open Library is the fallback and fills ISBN gaps, especially for Indian and
// self-published editions Google does not index.
//
// Every result is normalised and upserted into public.books, so the second user
// to scan the same ISBN costs zero external API quota and gets an instant answer.

import { handler, HttpError, json } from '../_shared/http.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

const GOOGLE_KEY = Deno.env.get('GOOGLE_BOOKS_API_KEY') ?? '';

interface BookDto {
  source: 'google' | 'openlibrary';
  source_id: string;
  isbn10: string | null;
  isbn13: string | null;
  title: string;
  subtitle: string | null;
  authors: string[];
  description: string | null;
  publisher: string | null;
  published_date: string | null;
  page_count: number | null;
  categories: string[];
  language: string | null;
  cover_url: string | null;
}

function normaliseIsbn(raw: string): string {
  return raw.replace(/[^0-9Xx]/g, '').toUpperCase();
}

// --------------------------------------------------------------------------
// Google Books
// --------------------------------------------------------------------------
async function searchGoogle(query: string, limit: number): Promise<BookDto[]> {
  const url = new URL('https://www.googleapis.com/books/v1/volumes');
  url.searchParams.set('q', query);
  url.searchParams.set('maxResults', String(Math.min(limit, 40)));
  url.searchParams.set('printType', 'books');
  if (GOOGLE_KEY) url.searchParams.set('key', GOOGLE_KEY);

  const res = await fetch(url);
  if (!res.ok) {
    console.warn('google books failed', res.status);
    return [];
  }
  const data = await res.json();

  return (data.items ?? []).map((item: Record<string, any>): BookDto => {
    const v = item.volumeInfo ?? {};
    const ids: Array<{ type: string; identifier: string }> = v.industryIdentifiers ?? [];
    const cover = v.imageLinks?.thumbnail ?? v.imageLinks?.smallThumbnail ?? null;
    return {
      source: 'google',
      source_id: item.id,
      isbn10: ids.find((i) => i.type === 'ISBN_10')?.identifier ?? null,
      isbn13: ids.find((i) => i.type === 'ISBN_13')?.identifier ?? null,
      title: v.title ?? 'Untitled',
      subtitle: v.subtitle ?? null,
      authors: v.authors ?? [],
      description: v.description ?? null,
      publisher: v.publisher ?? null,
      published_date: v.publishedDate ?? null,
      page_count: typeof v.pageCount === 'number' && v.pageCount > 0 ? v.pageCount : null,
      categories: v.categories ?? [],
      language: v.language ?? null,
      // Google serves http thumbnails; force https or iOS will refuse to load them.
      cover_url: cover ? cover.replace(/^http:/, 'https:') : null,
    };
  });
}

// --------------------------------------------------------------------------
// Open Library fallback
// --------------------------------------------------------------------------
async function searchOpenLibrary(query: string, limit: number): Promise<BookDto[]> {
  const url = new URL('https://openlibrary.org/search.json');
  url.searchParams.set('q', query);
  url.searchParams.set('limit', String(Math.min(limit, 20)));
  url.searchParams.set(
    'fields',
    'key,title,subtitle,author_name,first_publish_year,publisher,isbn,number_of_pages_median,subject,language,cover_i',
  );

  const res = await fetch(url, { headers: { 'User-Agent': 'Readora/1.0' } });
  if (!res.ok) return [];
  const data = await res.json();

  return (data.docs ?? []).map((d: Record<string, any>): BookDto => {
    const isbns: string[] = d.isbn ?? [];
    return {
      source: 'openlibrary',
      source_id: d.key,
      isbn10: isbns.find((i) => i.length === 10) ?? null,
      isbn13: isbns.find((i) => i.length === 13) ?? null,
      title: d.title ?? 'Untitled',
      subtitle: d.subtitle ?? null,
      authors: d.author_name ?? [],
      description: null,
      publisher: d.publisher?.[0] ?? null,
      published_date: d.first_publish_year ? String(d.first_publish_year) : null,
      page_count: d.number_of_pages_median ?? null,
      categories: (d.subject ?? []).slice(0, 8),
      language: d.language?.[0] ?? null,
      cover_url: d.cover_i ? `https://covers.openlibrary.org/b/id/${d.cover_i}-L.jpg` : null,
    };
  });
}

async function lookupIsbn(isbn: string): Promise<BookDto[]> {
  const google = await searchGoogle(`isbn:${isbn}`, 5);
  if (google.length > 0) return google;
  const ol = await searchOpenLibrary(isbn, 5);
  // Only trust an Open Library ISBN hit if it actually carries that ISBN.
  return ol.filter((b) => b.isbn10 === isbn || b.isbn13 === isbn).slice(0, 1);
}

Deno.serve(handler(async (req) => {
  await requireUser(req); // search is authenticated-only, to keep the quota ours

  const body = await req.json().catch(() => ({}));
  const rawIsbn = typeof body.isbn === 'string' ? normaliseIsbn(body.isbn) : '';
  const q = typeof body.q === 'string' ? body.q.trim() : '';
  const limit = Math.min(Number(body.limit ?? 20), 40);

  if (!rawIsbn && q.length < 2) {
    throw new HttpError(400, 'BAD_REQUEST', 'Provide `isbn` or a `q` of at least 2 characters.');
  }

  const admin = adminClient();

  // Cache hit path: an ISBN we have already normalised once never leaves the DB.
  if (rawIsbn) {
    const { data: cached } = await admin
      .from('books')
      .select('*')
      .or(`isbn13.eq.${rawIsbn},isbn10.eq.${rawIsbn}`)
      .limit(1);
    if (cached && cached.length > 0) {
      return json({ books: cached, cached: true });
    }
  }

  const results = rawIsbn ? await lookupIsbn(rawIsbn) : await searchGoogle(q, limit);
  const merged = results.length > 0 ? results : await searchOpenLibrary(q || rawIsbn, limit);

  if (merged.length === 0) return json({ books: [], cached: false });

  const { data: saved, error } = await admin
    .from('books')
    .upsert(merged, { onConflict: 'source,source_id' })
    .select();

  if (error) throw new HttpError(500, 'BOOK_CACHE_FAILED', error.message);

  return json({ books: saved, cached: false });
}));
