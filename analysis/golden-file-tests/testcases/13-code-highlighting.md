# Code Syntax Highlighting Test

## JavaScript

```javascript
function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

console.log(fibonacci(10));
```

## Python

```python
def quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quicksort(left) + middle + quicksort(right)

print(quicksort([3,6,8,10,1,2,1]))
```

## Swift

```swift
struct Person {
    let name: String
    var age: Int

    func greet() {
        print("Hello, my name is \(name)")
    }
}

let person = Person(name: "Alice", age: 30)
person.greet()
```

## C

```c
#include <stdio.h>

int main() {
    int n, i, sum = 0;
    printf("Enter a positive integer: ");
    scanf("%d", &n);

    for(i = 1; i <= n; ++i) {
        sum += i;
    }

    printf("Sum = %d", sum);
    return 0;
}
```

## Rust

```rust
fn main() {
    let numbers = vec![1, 2, 3, 4, 5];

    let sum: i32 = numbers.iter()
        .map(|x| x * x)
        .sum();

    println!("Sum of squares: {}", sum);
}
```

## Go

```go
package main

import "fmt"

func main() {
    ch := make(chan int)

    go func() {
        ch <- 42
    }()

    value := <-ch
    fmt.Println(value)
}
```

## HTML

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Example</title>
</head>
<body>
    <h1>Hello World!</h1>
    <p>This is a paragraph.</p>
</body>
</html>
```

## CSS

```css
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
    background-color: #f0f0f0;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
```

## JSON

```json
{
  "name": "example",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0",
    "lodash": "^4.17.21"
  },
  "scripts": {
    "start": "node index.js"
  }
}
```

## Shell/Bash

```bash
#!/bin/bash

for file in *.txt; do
    echo "Processing $file"
    wc -l "$file"
done

echo "Done processing files"
```

## SQL

```sql
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > '2024-01-01'
GROUP BY u.id, u.name
HAVING COUNT(o.id) > 5
ORDER BY order_count DESC;
```

## No Language Specified

```
This is a code block without a language.
It should be rendered as plain text.
No syntax highlighting applied.
```

## Unknown Language

```unknown-language-xyz
This uses an unknown language identifier.
Should fall back to plain text rendering.
```
