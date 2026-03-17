-- ── SQL Problems ─────────────────────────────────────────────────────────
ALTER TYPE problem_type ADD VALUE IF NOT EXISTS 'sql';

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sql-select-where',
  'Find Active Users',
  E'You have a `users` table. Write a query to return the `name` and `email` of all users where `active = true`, ordered by `name` ascending.

**Schema:**
```sql
users (id, name, email, active, created_at)
```

**Expected columns:** `name`, `email`',
  'sql', 'Easy', 'Databases', 80,
  ARRAY['Use WHERE to filter rows', 'Use ORDER BY name ASC to sort', 'You only need SELECT, FROM, WHERE, ORDER BY'],
  ARRAY['sql', 'select', 'where', 'order-by', 'databases'],
  ARRAY['sql']
) ON CONFLICT (slug) DO UPDATE SET description = EXCLUDED.description, hints = EXCLUDED.hints;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
VALUES (
  (SELECT id FROM problems WHERE slug = 'sql-select-where'),
  $setup$
CREATE TABLE users (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  email      TEXT NOT NULL,
  active     BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
INSERT INTO users (name, email, active) VALUES
  ('Alice',   'alice@example.com',   true),
  ('Bob',     'bob@example.com',     false),
  ('Charlie', 'charlie@example.com', true),
  ('Diana',   'diana@example.com',   true),
  ('Eve',     'eve@example.com',     false);
$setup$,
  $expected$SELECT name, email FROM users WHERE active = true ORDER BY name ASC$expected$,
  false, 0
) ON CONFLICT DO NOTHING;

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sql-inner-join',
  'Orders With Customer Names',
  E'Write a query that returns each order''s `id`, `total`, and the customer''s `name`.

**Schema:**
```sql
customers (id, name, email)
orders    (id, customer_id, total, status)
```

**Expected columns:** `order_id`, `total`, `name`

Only include orders that have a matching customer (INNER JOIN).',
  'sql', 'Easy', 'Databases', 100,
  ARRAY['JOIN customers ON orders.customer_id = customers.id', 'Alias orders.id as order_id', 'INNER JOIN only returns rows with matches on both sides'],
  ARRAY['sql', 'join', 'inner-join', 'databases'],
  ARRAY['sql']
) ON CONFLICT (slug) DO UPDATE SET description = EXCLUDED.description, hints = EXCLUDED.hints;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
VALUES (
  (SELECT id FROM problems WHERE slug = 'sql-inner-join'),
  $setup$
CREATE TABLE customers (
  id    SERIAL PRIMARY KEY,
  name  TEXT NOT NULL,
  email TEXT NOT NULL
);
CREATE TABLE orders (
  id          SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES customers(id),
  total       NUMERIC(10,2) NOT NULL,
  status      TEXT NOT NULL DEFAULT 'pending'
);
INSERT INTO customers (name, email) VALUES
  ('Alice', 'alice@example.com'),
  ('Bob',   'bob@example.com'),
  ('Carol', 'carol@example.com');
INSERT INTO orders (customer_id, total, status) VALUES
  (1, 99.99,  'completed'),
  (1, 149.50, 'pending'),
  (2, 49.00,  'completed'),
  (3, 200.00, 'cancelled');
$setup$,
  $expected$SELECT orders.id AS order_id, orders.total, customers.name FROM orders INNER JOIN customers ON orders.customer_id = customers.id$expected$,
  false, 0
) ON CONFLICT DO NOTHING;

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sql-group-having',
  'Customers With Multiple Orders',
  E'Find all customers who have placed **more than one order**.

Return the customer `name` and their `order_count`, ordered by `order_count` descending.

**Schema:**
```sql
customers (id, name, email)
orders    (id, customer_id, total, status)
```

**Expected columns:** `name`, `order_count`',
  'sql', 'Medium', 'Databases', 130,
  ARRAY['GROUP BY customer to count orders per customer', 'HAVING filters groups — use HAVING COUNT(*) > 1', 'JOIN customers to get the name', 'ORDER BY order_count DESC'],
  ARRAY['sql', 'group-by', 'having', 'aggregate', 'databases'],
  ARRAY['sql']
) ON CONFLICT (slug) DO UPDATE SET description = EXCLUDED.description, hints = EXCLUDED.hints;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
VALUES (
  (SELECT id FROM problems WHERE slug = 'sql-group-having'),
  $setup$
CREATE TABLE customers (
  id    SERIAL PRIMARY KEY,
  name  TEXT NOT NULL,
  email TEXT NOT NULL
);
CREATE TABLE orders (
  id          SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES customers(id),
  total       NUMERIC(10,2) NOT NULL,
  status      TEXT NOT NULL DEFAULT 'pending'
);
INSERT INTO customers (name, email) VALUES
  ('Alice', 'alice@example.com'),
  ('Bob',   'bob@example.com'),
  ('Carol', 'carol@example.com'),
  ('Dave',  'dave@example.com');
INSERT INTO orders (customer_id, total, status) VALUES
  (1, 99.99,  'completed'),
  (1, 149.50, 'completed'),
  (1, 30.00,  'pending'),
  (2, 49.00,  'completed'),
  (3, 200.00, 'completed'),
  (3, 75.00,  'completed');
$setup$,
  $expected$SELECT customers.name, COUNT(orders.id) AS order_count FROM customers JOIN orders ON customers.id = orders.customer_id GROUP BY customers.name HAVING COUNT(orders.id) > 1 ORDER BY order_count DESC$expected$,
  false, 0
) ON CONFLICT DO NOTHING;

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sql-subquery',
  'Products Above Average Price',
  E'Write a query to find all products whose `price` is **above the average price** of all products.

Return `name` and `price`, ordered by `price` descending.

**Schema:**
```sql
products (id, name, price, category)
```

**Expected columns:** `name`, `price`',
  'sql', 'Medium', 'Databases', 130,
  ARRAY['Calculate the average with a subquery: (SELECT AVG(price) FROM products)', 'Use WHERE price > (subquery)', 'ORDER BY price DESC'],
  ARRAY['sql', 'subquery', 'aggregate', 'databases'],
  ARRAY['sql']
) ON CONFLICT (slug) DO UPDATE SET description = EXCLUDED.description, hints = EXCLUDED.hints;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
VALUES (
  (SELECT id FROM problems WHERE slug = 'sql-subquery'),
  $setup$
CREATE TABLE products (
  id       SERIAL PRIMARY KEY,
  name     TEXT NOT NULL,
  price    NUMERIC(10,2) NOT NULL,
  category TEXT NOT NULL
);
INSERT INTO products (name, price, category) VALUES
  ('Keyboard',    79.99,  'Electronics'),
  ('Mouse',       29.99,  'Electronics'),
  ('Monitor',    349.99,  'Electronics'),
  ('Desk',       199.99,  'Furniture'),
  ('Chair',      249.99,  'Furniture'),
  ('Webcam',      59.99,  'Electronics'),
  ('Headphones', 149.99,  'Electronics');
$setup$,
  $expected$SELECT name, price FROM products WHERE price > (SELECT AVG(price) FROM products) ORDER BY price DESC$expected$,
  false, 0
) ON CONFLICT DO NOTHING;

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sql-window-rank',
  'Rank Employees by Salary',
  E'Write a query that returns each employee''s `name`, `department`, `salary`, and their `salary_rank` **within their department** (1 = highest paid).

**Schema:**
```sql
employees (id, name, department, salary)
```

**Expected columns:** `name`, `department`, `salary`, `salary_rank`

Order results by `department` ASC, then `salary_rank` ASC.',
  'sql', 'Hard', 'Databases', 200,
  ARRAY['Use RANK() or DENSE_RANK() window function', 'PARTITION BY department groups the ranking within each dept', 'ORDER BY salary DESC inside the window gives rank 1 to highest', 'Syntax: RANK() OVER (PARTITION BY department ORDER BY salary DESC)'],
  ARRAY['sql', 'window-functions', 'rank', 'advanced', 'databases'],
  ARRAY['sql']
) ON CONFLICT (slug) DO UPDATE SET description = EXCLUDED.description, hints = EXCLUDED.hints;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
VALUES (
  (SELECT id FROM problems WHERE slug = 'sql-window-rank'),
  $setup$
CREATE TABLE employees (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  department TEXT NOT NULL,
  salary     NUMERIC(10,2) NOT NULL
);
INSERT INTO employees (name, department, salary) VALUES
  ('Alice',   'Engineering', 120000),
  ('Bob',     'Engineering',  95000),
  ('Carol',   'Engineering', 110000),
  ('Dave',    'Marketing',    80000),
  ('Eve',     'Marketing',    90000),
  ('Frank',   'Marketing',    75000),
  ('Grace',   'HR',           70000),
  ('Heidi',   'HR',           72000);
$setup$,
  $expected$SELECT name, department, salary, RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank FROM employees ORDER BY department ASC, salary_rank ASC$expected$,
  false, 0
) ON CONFLICT DO NOTHING;

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sql-debug-query',
  'Debug: Fix the Broken Query',
  E'The following query is supposed to return the **total revenue per category** for completed orders only, but it has **two bugs**. Find and fix them.

```sql
SELECT category, SUM(price * quantity) AS revenue
FROM order_items
JOIN products ON order_items.product_id = products.id
JOIN orders ON order_items.order_id = orders.id
WHERE orders.status = "completed"
GROUP BY order_items.category
ORDER BY revenue DESC;
```

**Schema:**
```sql
products    (id, name, price, category)
orders      (id, status)
order_items (id, order_id, product_id, quantity)
```

**Expected columns:** `category`, `revenue`',
  'sql', 'Hard', 'Databases', 180,
  ARRAY['SQL strings use single quotes, not double quotes', 'The GROUP BY column is wrong — what table does category belong to?', 'Check which table actually has the category column'],
  ARRAY['sql', 'debug', 'group-by', 'join', 'databases'],
  ARRAY['sql']
) ON CONFLICT (slug) DO UPDATE SET description = EXCLUDED.description, hints = EXCLUDED.hints;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
VALUES (
  (SELECT id FROM problems WHERE slug = 'sql-debug-query'),
  $setup$
CREATE TABLE products (
  id       SERIAL PRIMARY KEY,
  name     TEXT NOT NULL,
  price    NUMERIC(10,2) NOT NULL,
  category TEXT NOT NULL
);
CREATE TABLE orders (
  id     SERIAL PRIMARY KEY,
  status TEXT NOT NULL
);
CREATE TABLE order_items (
  id         SERIAL PRIMARY KEY,
  order_id   INTEGER REFERENCES orders(id),
  product_id INTEGER REFERENCES products(id),
  quantity   INTEGER NOT NULL
);
INSERT INTO products (name, price, category) VALUES
  ('Keyboard',   79.99, 'Electronics'),
  ('Mouse',      29.99, 'Electronics'),
  ('Desk',      199.99, 'Furniture'),
  ('Chair',     249.99, 'Furniture');
INSERT INTO orders (status) VALUES ('completed'),('completed'),('pending');
INSERT INTO order_items (order_id, product_id, quantity) VALUES
  (1, 1, 2), (1, 3, 1),
  (2, 2, 3), (2, 4, 1),
  (3, 1, 1);
$setup$,
  $expected$SELECT products.category, SUM(products.price * order_items.quantity) AS revenue FROM order_items JOIN products ON order_items.product_id = products.id JOIN orders ON order_items.order_id = orders.id WHERE orders.status = 'completed' GROUP BY products.category ORDER BY revenue DESC$expected$,
  false, 0
) ON CONFLICT DO NOTHING;