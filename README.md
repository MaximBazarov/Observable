# Observable
Tiny framework for making any value easy observable

Any proposals, suggestions, issues, PRs are welcome

## Usage:

```swift
class SomeClass {
    var valueNeedsObserving = Observable(7)
}

/// ... some other place

let some = SomeClass()
let unsubscribeFromValueNeedsObserving = some.ValueNeedsObserving.subscribe { value in
      print(v) // you print value every time when it changes
}


valueNeedsObserving.value = 10
// closure above will print 10


/// ... later unsubscribe if needed
deinit {
      unsubscribeFromValueNeedsObserving()
}
```
