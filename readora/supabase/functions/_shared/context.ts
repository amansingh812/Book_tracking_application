// Builds the AI context for a book.
//
// COPYRIGHT BOUNDARY - read this before extending:
// Readora never sends book text it is not authorised to hold. The context is built
// from (a) public bibliographic metadata and (b) the user's OWN notes, highlights,
// rating and progress. If a feature seems to need the book's actual text, the answer
// is to ask the user to paste the passage they are looking at, not to source it.

import type { SupabaseClient } from 'npm:@supabase/supabase-js@2';
import { HttpError } from './http.ts';

export interface BookContext {
  userBookId: string;
  title: string;
  authors: string[];
  categories: string[];
  pageCount: number | null;
  currentPage: number;
  status: string;
  rating: number | null;
  notes: Array<{ kind: string; page: number | null; chapter: string | null; content: string }>;
}

const MAX_NOTES = 60;
const MAX_NOTE_CHARS = 600;

export async function loadBookContext(
  db: SupabaseClient,
  userBookId: string,
): Promise<BookContext> {
  // RLS guarantees this returns nothing if the row is not the caller's.
  const { data: ub, error } = await db
    .from('user_books')
    .select('id, status, current_page, rating, page_count_override, books(title, authors, categories, page_count)')
    .eq('id', userBookId)
    .is('deleted_at', null)
    .maybeSingle();

  if (error) throw new HttpError(500, 'CONTEXT_LOAD_FAILED', error.message);
  if (!ub) throw new HttpError(404, 'BOOK_NOT_FOUND', 'That book is not in your library.');

  const book = (ub as Record<string, any>).books ?? {};

  const { data: notes } = await db
    .from('notes')
    .select('kind, page, chapter, content')
    .eq('user_book_id', userBookId)
    .is('deleted_at', null)
    .order('page', { ascending: true, nullsFirst: false })
    .limit(MAX_NOTES);

  return {
    userBookId,
    title: book.title ?? 'Unknown title',
    authors: book.authors ?? [],
    categories: book.categories ?? [],
    pageCount: (ub as any).page_count_override ?? book.page_count ?? null,
    currentPage: (ub as any).current_page ?? 0,
    status: (ub as any).status ?? 'reading',
    rating: (ub as any).rating ?? null,
    notes: (notes ?? []).map((n: Record<string, any>) => ({
      kind: n.kind,
      page: n.page,
      chapter: n.chapter,
      content: String(n.content).slice(0, MAX_NOTE_CHARS),
    })),
  };
}

export function renderContext(ctx: BookContext): string {
  const progress = ctx.pageCount
    ? `${ctx.currentPage} of ${ctx.pageCount} pages (${Math.round((ctx.currentPage / ctx.pageCount) * 100)}%)`
    : `page ${ctx.currentPage}`;

  const notes = ctx.notes.length === 0
    ? 'The reader has not saved any notes or highlights for this book yet.'
    : ctx.notes
        .map((n) => `- [${n.kind}${n.page ? `, p.${n.page}` : ''}] ${n.content}`)
        .join('\n');

  return [
    `BOOK: ${ctx.title}`,
    `AUTHOR(S): ${ctx.authors.join(', ') || 'unknown'}`,
    `SUBJECTS: ${ctx.categories.join(', ') || 'unspecified'}`,
    `READER PROGRESS: ${progress} (status: ${ctx.status})`,
    ctx.rating ? `READER RATING: ${ctx.rating / 2} / 5` : '',
    '',
    "READER'S OWN NOTES AND HIGHLIGHTS:",
    notes,
  ].filter(Boolean).join('\n');
}

export const READORA_SYSTEM_PROMPT = `You are Readora's reading companion.

You help one reader understand, remember, and apply what they read.

Rules:
- Ground every answer in the reader's own notes and highlights, which are supplied to you. Quote them back when relevant.
- You may draw on general knowledge about the book and its ideas, but never reproduce extended passages of the book's text.
- If the reader asks about something their notes do not cover, say so plainly and offer to work from a passage they paste in.
- Be concise. A reader on a phone wants three tight paragraphs, not an essay.
- Never invent notes, page numbers, or quotes the reader did not write.
- Respect where they are in the book: do not spoil content past their current page unless they ask.`;
