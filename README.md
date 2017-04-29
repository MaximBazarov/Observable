# Observable
Tiny framework for making any value easy observable

Any proposals, suggestions, issues, PRs are welcome

## Usage: 

```swift
class SomeClass {
    let ValueNeedsObserving = Observable<Int?>(7)
}

/// ... some other place

let some = SomeClass()
let unsubscribe = some.ValueNeedsObserving.subscribe { v in
    print(v)
}

/// ... later unsubscribe if needed

unsubscribe()
```

## Needs
 * Red tests
 
## Don't like 
* Signatures like Observable<Int?>(7) looks ugly to me, may be possible better design


