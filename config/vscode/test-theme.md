# Flexoki Theme Test

Body text should be default tx color, not purple, not dimmed.

## Markdown Basics

**Bold text** should be bold, no color change.
*Italic text* should be italic, no color change.
~~Strikethrough~~ should be struck through.
`inline code` should be purple.

- List item body text should be default tx color
- Not dimmed like the bullet marker
  - Nested list too
  1. Numbered list item

> Blockquote text should be dimmed italic

[Link text](https://example.com) — link URL should be cyan.
![Image alt](image.png)

---

## JavaScript / TypeScript

```javascript
// Comments should be tx-3 italic
/* Block comment */

// Keywords (green): let, const, var, function, class, if, for, return
const x = 42;
let name = "hello";
var old = true;

// Import/export (red)
import { useState } from 'react';
export default App;
import * as fs from 'fs';

// Functions (orange)
function greet(name) {
  return `Hello, ${name}!`;  // template literal, ${} magenta
}
const arrow = (x) => x * 2;
console.log(greet("world"));

// Types would need TS, but support.class:
new Map();
new Promise((resolve) => resolve());

// Numbers (purple)
const num = 3.14;
const hex = 0xFF;
const bin = 0b1010;

// Booleans/null (magenta — constant.language)
const flag = true;
const empty = null;
const undef = undefined;

// Regex
const pattern = /^hello\s+world$/gi;

// Operators (tx-2)
x === 1 && y !== 2 || z >= 3;
const spread = { ...obj, key: value };

// Object properties (tx — default text)
const obj = { foo: 1, bar: "two" };
obj.foo;
obj.bar.length;

// String escapes
const escaped = "line1\nline2\ttab";
```

```typescript
// TypeScript type annotations (yellow)
interface User {
  name: string;
  age: number;
  active: boolean;
}

type Result<T> = { ok: true; value: T } | { ok: false; error: string };

class Service implements User {
  private name: string;
  public age: number;
  readonly active: boolean = true;

  constructor(name: string) {
    this.name = name;  // this = magenta
  }

  async fetch(): Promise<User[]> {
    return [];
  }
}

// Decorators (magenta)
@Component({ selector: 'app' })
class AppComponent {}

// Enum
enum Direction {
  Up,
  Down,
  Left,
  Right,
}
```

## Python

```python
# Comment (tx-3 italic)

# Keywords (green): def, class, if, for, return, with, as, from, import
# Import (red)
import os
from pathlib import Path
from typing import Optional, List

# Functions (orange)
def greet(name: str) -> str:
    """Docstring should be tx-3 italic"""
    return f"Hello, {name}!"  # f-string interpolation

# Class
class User:
    def __init__(self, name: str, age: int = 0):
        self.name = name   # self = magenta
        self.age = age

    @staticmethod       # decorator = magenta
    def create(name: str) -> "User":
        return User(name)

    @property
    def display(self) -> str:
        return f"{self.name} ({self.age})"

# Booleans/None (magenta)
flag = True
empty = None
check = False

# Numbers (purple)
pi = 3.14159
count = 42
big = 1_000_000

# Type hints (should be yellow via support.type)
def process(items: List[str], count: Optional[int] = None) -> bool:
    pass

# Lambda
fn = lambda x, y: x + y

# String types
raw = r"no \n escape"
multi = """
multiline
string
"""
```

## C / C++

```cpp
#include <iostream>    // #include — is this red (import) or green (keyword)?
#include <string>
#include <vector>

// Primitive types (yellow via storage.type.built-in)
int main(int argc, char *argv[]) {   // * = tx-2 (pointer)
    // Type references
    std::string name = "test";       // std = yellow (namespace), string = yellow (type)
    std::vector<int> nums = {1, 2, 3};
    bool flag = false;               // bool = yellow, false = magenta
    unsigned long count = 0;
    const double pi = 3.14159;       // const = green (keyword), double = yellow

    // Reference parameter
    auto& ref = name;                // & = tx-2 (reference)

    // Pointer
    int* ptr = nullptr;              // * = tx-2, nullptr = magenta

    // Control flow (green)
    if (flag) {
        for (auto& n : nums) {
            std::cout << n << "\n";
        }
    }

    // Function call
    std::sort(nums.begin(), nums.end());

    return 0;
}

// Class/struct
struct Point {
    double x, y;
};

class Graph {
public:
    virtual void draw() = 0;        // virtual = green (keyword)
    static int count;
protected:
    int nodes;
};

// Template
template <typename T>
T max(T a, T b) {
    return (a > b) ? a : b;
}

// Preprocessor (magenta)
#define MAX_SIZE 100
#ifdef DEBUG
#endif

// Enum
enum Color { Red, Green, Blue };
```

## Java

```java
package com.example;

import java.util.List;        // import = red
import java.util.Map;
import java.util.stream.Collectors;

// Class (yellow via storage.type.java override)
public class DataProcessor<T extends Comparable<T>> {
    // Primitive types (yellow)
    private int count;
    private boolean active;
    private double threshold;

    // Reference types (yellow)
    private List<T> items;
    private Map<String, Integer> cache;

    // Constructor
    public DataProcessor(List<T> items) {
        this.items = items;    // this = magenta
        this.count = 0;
    }

    // Method with generics
    public <R> List<R> transform(java.util.function.Function<T, R> mapper) {
        return items.stream()
            .map(mapper)
            .collect(Collectors.toList());
    }

    // Static method
    public static void main(String[] args) {
        var processor = new DataProcessor<>(List.of(1, 2, 3));
        System.out.println(processor.count);
    }

    // Enum
    enum Status {
        ACTIVE,
        INACTIVE,
        PENDING
    }

    // Constants
    public static final int MAX_RETRIES = 3;
    private static final String DEFAULT_NAME = "unnamed";
}

// Interface
interface Processable<T> {
    boolean process(T item);
    default void reset() {}
}

// Annotation
@Override
@SuppressWarnings("unchecked")
public String toString() {
    return "DataProcessor";
}
```

## JSON

```json
{
  "name": "flexoki",
  "version": "0.1.0",
  "private": true,
  "count": 42,
  "ratio": 3.14,
  "active": false,
  "data": null,
  "tags": ["theme", "color"],
  "nested": {
    "deep": {
      "value": 100
    }
  }
}
```

## SQL

```sql
-- Comment (tx-3)
SELECT
    c.customer_account_number,
    c.name,
    SUM(b.amount) AS total_credits,
    COUNT(*) AS credit_count
FROM bill_credits b
INNER JOIN customers c ON c.id = b.customer_id
WHERE b.created_at >= '2024-01-01'
    AND b.status = 'approved'
    AND b.amount > 0
GROUP BY c.customer_account_number, c.name
HAVING SUM(b.amount) > 100.00
ORDER BY total_credits DESC
LIMIT 50;

-- DDL
CREATE TABLE IF NOT EXISTS bill_credits (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert
INSERT INTO bill_credits (customer_id, amount, status)
VALUES (1, 25.50, 'approved');

-- Update
UPDATE bill_credits
SET status = 'void', amount = 0
WHERE id = 42;
```

## CSS

```css
/* Comment (tx-3) */

/* Selectors (yellow) */
.container { }
#main { }
.btn:hover { }
.btn::after { }

/* Properties (blue), values (orange), units (purple) */
.card {
  display: flex;
  flex-direction: column;
  padding: 16px;
  margin: 0 auto;
  max-width: 800px;
  font-size: 1.125rem;
  line-height: 1.5;
  color: #333;
  background-color: rgba(255, 255, 255, 0.95);
  border: 1px solid transparent;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease-in-out;
}

/* Media query */
@media (max-width: 768px) {
  .card {
    padding: 8px;
  }
}

/* Custom properties */
:root {
  --color-primary: #205EA6;
  --spacing-md: 16px;
}

/* Important */
.override {
  color: red !important;
}
```

## HTML

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Test Page</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container" id="app" data-theme="dark">
    <h1>Hello World</h1>
    <p>Paragraph with <strong>bold</strong> and <em>italic</em>.</p>
    <a href="https://example.com" target="_blank">Link</a>
    <img src="image.png" alt="Description" />
    <input type="text" placeholder="Enter text" disabled />
    <!-- Comment -->
  </div>
  <script src="app.js"></script>
</body>
</html>
```

## Shell

```bash
#!/bin/bash

# Comment (tx-3)

# Variables (blue?)
NAME="world"
COUNT=42

# String interpolation
echo "Hello, ${NAME}!"
echo "Count is: $COUNT"

# Keywords (green): if, then, fi, for, do, done, case, esac
if [ "$COUNT" -gt 10 ]; then
    echo "big number"
fi

for file in *.txt; do
    echo "$file"
done

# Functions (orange?)
greet() {
    local msg="Hello, $1"
    echo "$msg"
}

# Pipes and redirects (tx-2?)
cat file.txt | grep "pattern" | sort | uniq > output.txt 2>&1

# Command substitution
DATE=$(date +%Y-%m-%d)
FILES=$(ls -la)

# Exit codes
exit 0
```

## YAML

```yaml
# Comment
name: flexoki-theme
version: 0.1.0

services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    environment:
      NODE_ENV: production
      DEBUG: "false"
      MAX_CONNECTIONS: 100
    volumes:
      - ./data:/app/data
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: myapp
```

## TOML

```toml
# Comment
[package]
name = "flexoki"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1", features = ["full"] }

[profile.release]
opt-level = 3
lto = true
strip = true

[[bin]]
name = "cli"
path = "src/main.rs"
```

## Nix

```nix
# Comment
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Attribute names (blue)
  programs.git = {
    enable = true;
    userName = "Test User";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Packages
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
  ];

  # String interpolation
  home.file.".config/test".text = ''
    value = ${config.home.username}
    path = ${pkgs.ripgrep}/bin/rg
  '';

  # Let binding
  environment.systemPackages =
    let
      customPkg = pkgs.writeShellScriptBin "hello" ''
        echo "Hello, world!"
      '';
    in
    [ customPkg ];

  # Conditional
  services.openssh.enable = lib.mkIf (!config.isWSL) true;
}
```

## XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <appSettings>
    <add key="ApiUrl" value="https://api.example.com" />
    <add key="MaxRetries" value="3" />
    <add key="Enabled" value="true" />
  </appSettings>
  <connectionStrings>
    <add name="Default"
         connectionString="Server=localhost;Database=mydb"
         providerName="System.Data.SqlClient" />
  </connectionStrings>
  <!-- Comment -->
</configuration>
```
