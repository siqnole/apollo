-- Add html_css to the problem_type enum
ALTER TYPE problem_type ADD VALUE IF NOT EXISTS 'html_css';

-- ── HTML/CSS Problems ──────────────────────────────────────────────────────

-- 1. Flexbox row
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'flexbox-row-center',
  'Flexbox: Centre Three Items',
  E'Create a container `div` with the class `container` that uses **Flexbox** to display three child `div` elements **horizontally**, evenly spaced, and vertically centred within a `200px` tall container.\n\nEach child should have the class `item`.\n\n**Requirements:**\n- Container uses `display: flex`\n- Items are in a row (horizontal)\n- Items are evenly spaced (`justify-content: space-evenly` or similar)\n- Container is exactly `200px` tall\n- At least 3 `.item` children exist',
  'html_css', 'Easy', 'Web Development', 80,
  '{"html":"<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    .container {\n      /* your styles here */\n    }\n    .item {\n      width: 60px;\n      height: 60px;\n      background: #C9A84C;\n    }\n  </style>\n</head>\n<body>\n  <div class=\"container\">\n    <div class=\"item\"></div>\n    <div class=\"item\"></div>\n    <div class=\"item\"></div>\n  </div>\n</body>\n</html>"}',
  ARRAY['display: flex goes on the parent container', 'justify-content controls horizontal spacing', 'align-items controls vertical alignment'],
  ARRAY['flexbox', 'css', 'layout']
);

-- 2. 3x3 Grid
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'css-grid-3x3',
  'CSS Grid: Build a 3×3 Table',
  E'Create a `div` with class `grid` that displays **9 child elements** in a **3 column × 3 row** grid using CSS Grid.\n\nEach cell should have the class `cell`.\n\n**Requirements:**\n- Uses `display: grid`\n- Exactly 3 columns\n- Exactly 9 `.cell` children\n- Each cell is at least `80px × 80px`\n- A visible gap between cells',
  'html_css', 'Easy', 'Web Development', 80,
  '{"html":"<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    .grid {\n      /* your styles here */\n    }\n    .cell {\n      background: #1C1812;\n      border: 1px solid #C9A84C;\n      display: flex;\n      align-items: center;\n      justify-content: center;\n      color: #C9A84C;\n      font-family: monospace;\n    }\n  </style>\n</head>\n<body>\n  <div class=\"grid\">\n    <div class=\"cell\">1</div>\n    <div class=\"cell\">2</div>\n    <div class=\"cell\">3</div>\n    <div class=\"cell\">4</div>\n    <div class=\"cell\">5</div>\n    <div class=\"cell\">6</div>\n    <div class=\"cell\">7</div>\n    <div class=\"cell\">8</div>\n    <div class=\"cell\">9</div>\n  </div>\n</body>\n</html>"}',
  ARRAY['grid-template-columns: repeat(3, 1fr) creates 3 equal columns', 'gap property adds space between cells', 'min-height or height on .cell sets the size'],
  ARRAY['css-grid', 'css', 'layout']
);

-- 3. Uneven grid (3x3 but last row has 4 columns)
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'css-grid-uneven',
  'CSS Grid: 3×3 With a 4-Column Last Row',
  E'Build a grid where the first **two rows have 3 columns** each, but the **last row has 4 columns**.\n\nUse a `div` with class `grid` and individual `div.cell` children.\n\n**Requirements:**\n- First 6 cells form a 3-column layout\n- Last 4 cells form a 4-column layout\n- No JavaScript — CSS/HTML only\n- Visible borders or backgrounds on each cell\n\n**Hint:** Consider using `grid-column: span` or a subgrid, or simply nesting two separate grid containers.',
  'html_css', 'Medium', 'Web Development', 120,
  '{"html":"<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    .grid-top {\n      /* 3 columns */\n    }\n    .grid-bottom {\n      /* 4 columns */\n    }\n    .cell {\n      background: #1C1812;\n      border: 1px solid #C9A84C;\n      min-height: 80px;\n      display: flex;\n      align-items: center;\n      justify-content: center;\n      color: #C9A84C;\n      font-family: monospace;\n    }\n  </style>\n</head>\n<body>\n  <div class=\"grid-top\">\n    <div class=\"cell\">1</div>\n    <div class=\"cell\">2</div>\n    <div class=\"cell\">3</div>\n    <div class=\"cell\">4</div>\n    <div class=\"cell\">5</div>\n    <div class=\"cell\">6</div>\n  </div>\n  <div class=\"grid-bottom\">\n    <div class=\"cell\">7</div>\n    <div class=\"cell\">8</div>\n    <div class=\"cell\">9</div>\n    <div class=\"cell\">10</div>\n  </div>\n</body>\n</html>"}',
  ARRAY['Two separate grid containers is perfectly valid', 'grid-template-columns: repeat(3, 1fr) vs repeat(4, 1fr)', 'You could also use one grid with grid-column: span'],
  ARRAY['css-grid', 'css', 'layout', 'advanced']
);

-- 4. Responsive navbar
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'html-navbar',
  'Build a Navigation Bar',
  E'Create a semantic HTML `<nav>` element containing an unordered list of **4 navigation links**. Style it so the links display **horizontally** in a single row.\n\n**Requirements:**\n- Uses a `<nav>` element\n- Contains a `<ul>` with exactly **4 `<li>` items**\n- Each `<li>` contains an `<a>` tag\n- Links display horizontally (not stacked)\n- List bullets are hidden (`list-style: none`)',
  'html_css', 'Easy', 'Web Development', 60,
  '{"html":"<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    nav ul {\n      /* your styles */\n    }\n    nav li {\n      /* your styles */\n    }\n    nav a {\n      color: #C9A84C;\n      text-decoration: none;\n      font-family: monospace;\n    }\n  </style>\n</head>\n<body>\n  <nav>\n    <ul>\n      <li><a href=\"#\">Home</a></li>\n      <li><a href=\"#\">About</a></li>\n      <li><a href=\"#\">Work</a></li>\n      <li><a href=\"#\">Contact</a></li>\n    </ul>\n  </nav>\n</body>\n</html>"}',
  ARRAY['display: flex on the <ul> makes children horizontal', 'Or use display: inline on each <li>', 'list-style: none removes the bullet points'],
  ARRAY['html', 'css', 'navigation', 'flexbox']
);

-- 5. Card with box shadow
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'css-card',
  'CSS Card Component',
  E'Style a card component with the class `card` that looks polished:\n\n**Requirements:**\n- Rounded corners (`border-radius` ≥ 8px)\n- A visible `box-shadow`\n- Internal padding of at least `16px`\n- A `max-width` of `320px`\n- Contains an `<h2>` title and a `<p>` description',
  'html_css', 'Easy', 'UI/UX', 70,
  '{"html":"<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    body {\n      background: #0A0906;\n      display: flex;\n      justify-content: center;\n      padding: 40px;\n    }\n    .card {\n      /* your styles here */\n      background: #1C1812;\n      color: #F0E8D6;\n      font-family: sans-serif;\n    }\n    .card h2 { margin-top: 0; color: #C9A84C; }\n  </style>\n</head>\n<body>\n  <div class=\"card\">\n    <h2>Apollo Card</h2>\n    <p>This is a sample card component. Style me to look great!</p>\n  </div>\n</body>\n</html>"}',
  ARRAY['border-radius: 12px gives nice rounded corners', 'box-shadow: 0 4px 20px rgba(0,0,0,0.4) is a good starting point', 'padding: 24px adds comfortable internal spacing'],
  ARRAY['css', 'components', 'box-model', 'ui']
);

-- 6. Flexbox column with gap
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'flexbox-column',
  'Flexbox: Vertical Stack With Gap',
  E'Create a `.stack` container that stacks its children **vertically** with a `16px` gap between them. The container should stretch to the full width of the viewport.\n\n**Requirements:**\n- Uses `display: flex`\n- Children stacked vertically (`flex-direction: column`)\n- Exactly `16px` gap between items\n- At least 3 `.card` children visible\n- Full width container',
  'html_css', 'Easy', 'Web Development', 70,
  '{"html":"<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    body { background: #0A0906; padding: 20px; margin: 0; }\n    .stack {\n      /* your styles here */\n    }\n    .card {\n      background: #1C1812;\n      border: 1px solid rgba(201,168,76,0.3);\n      padding: 20px;\n      color: #F0E8D6;\n      font-family: monospace;\n    }\n  </style>\n</head>\n<body>\n  <div class=\"stack\">\n    <div class=\"card\">Item One</div>\n    <div class=\"card\">Item Two</div>\n    <div class=\"card\">Item Three</div>\n  </div>\n</body>\n</html>"}',
  ARRAY['flex-direction: column stacks children vertically', 'gap: 16px adds space between flex children', 'width: 100% makes the container full width'],
  ARRAY['flexbox', 'css', 'layout']
);

-- 7. Position: sticky header
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'css-sticky-header',
  'CSS: Sticky Header',
  E'Make the `<header>` element stick to the top of the viewport as the user scrolls. The page should have enough content to actually scroll.\n\n**Requirements:**\n- `<header>` uses `position: sticky` or `position: fixed`\n- Header stays at the top when scrolling\n- Header has a visible background (not transparent)\n- At least `500px` of content below the header to demonstrate scrolling\n- Header `z-index` high enough to appear above content',
  'html_css', 'Medium', 'Web Development', 90,
  '{"html":"<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    * { margin: 0; padding: 0; box-sizing: border-box; }\n    body { background: #0A0906; color: #F0E8D6; font-family: monospace; }\n    header {\n      /* make me sticky */\n      background: #1C1812;\n      padding: 16px 24px;\n      border-bottom: 1px solid rgba(201,168,76,0.3);\n      color: #C9A84C;\n    }\n    main {\n      padding: 24px;\n    }\n  </style>\n</head>\n<body>\n  <header>APOLLO.GG — Sticky Header</header>\n  <main>\n    <p>Scroll down to test the sticky header...</p>\n    <div style=\"height: 1200px; padding-top: 20px; color: #4A4236;\">\n      Lots of content here...\n    </div>\n  </main>\n</body>\n</html>"}',
  ARRAY['position: sticky requires a top value (e.g. top: 0)', 'position: fixed always stays at the top regardless of scroll', 'z-index: 100 ensures it appears above other content'],
  ARRAY['css', 'positioning', 'layout']
);

-- 8. HTML Table
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'html-table',
  'HTML Table: Student Grades',
  E'Create a proper HTML table showing student grades with:\n\n**Requirements:**\n- A `<table>` element\n- A `<thead>` with column headers: **Name**, **Subject**, **Grade**\n- A `<tbody>` with at least **3 data rows**\n- Styled with borders or background alternating rows\n- Uses `<th>` for headers and `<td>` for data cells',
  'html_css', 'Easy', 'Web Development', 60,
  '{"html":"<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    body { background: #0A0906; color: #F0E8D6; font-family: monospace; padding: 20px; }\n    table {\n      /* your styles */\n      width: 100%;\n      border-collapse: collapse;\n    }\n    th {\n      /* header styles */\n    }\n    td {\n      /* cell styles */\n    }\n  </style>\n</head>\n<body>\n  <table>\n    <thead>\n      <tr>\n        <th>Name</th>\n        <th>Subject</th>\n        <th>Grade</th>\n      </tr>\n    </thead>\n    <tbody>\n      <!-- Add your rows here -->\n    </tbody>\n  </table>\n</body>\n</html>"}',
  ARRAY['<tr> creates a table row', '<td> creates a table cell, <th> creates a header cell', 'border-collapse: collapse removes double borders'],
  ARRAY['html', 'tables', 'semantics']
);