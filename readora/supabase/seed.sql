-- seed.sql - runs after `supabase db reset` on the LOCAL stack only.
-- Gives you a few real books to search against without burning Google Books quota.

insert into public.books
  (source, source_id, isbn13, isbn10, title, subtitle, authors, description,
   publisher, published_date, page_count, categories, language, cover_url)
values
  ('google', 'seed-atomic-habits', '9781847941831', '1847941834',
   'Atomic Habits', 'An Easy & Proven Way to Build Good Habits & Break Bad Ones',
   array['James Clear'],
   'A framework for improving every day through small changes that compound.',
   'Random House Business', '2018-10-16', 320,
   array['Self-Help', 'Psychology'], 'en', null),

  ('google', 'seed-deep-work', '9780349411903', '0349411905',
   'Deep Work', 'Rules for Focused Success in a Distracted World',
   array['Cal Newport'],
   'An argument for the value of sustained concentration, and how to train it.',
   'Piatkus', '2016-01-05', 304,
   array['Business', 'Self-Help'], 'en', null),

  ('google', 'seed-psych-money', '9780857197689', '0857197681',
   'The Psychology of Money', 'Timeless Lessons on Wealth, Greed, and Happiness',
   array['Morgan Housel'],
   'Nineteen short stories about the strange ways people think about money.',
   'Harriman House', '2020-09-08', 256,
   array['Business', 'Finance'], 'en', null)
on conflict (source, source_id) do nothing;
