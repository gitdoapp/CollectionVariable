# RAC-MutableCollectionProperty
[![Build Status](https://travis-ci.org/gitdoapp/RAC-MutableCollectionProperty.svg)](https://travis-ci.org/gitdoapp/RAC-MutableCollectionProperty)

Implementation of the concept of MutableCollectionProperty for ReactiveCocoa (Swift)

*Implemented by [@pepibumur](https://github.com/pepibumur)*

### Features
- Swift 2.0
- Granularity reporting collection changes (custom events)
- It exposes Swift Array collection methods
- NSFetchedResultsController inspired
- ReactiveCocoa 4.XX

## How to install
1. Get [Carthage](https://github.com/Carthage/Carthage), `brew update carthage`
2. Add the line `github "gitdoapp/RAC-MutableCollectionProperty"` to your `Cartfile`
3. Execute `carthage update`
4. Add the Carthage generated frameworks to your project following the steps [here](https://github.com/Carthage/Carthage).

## How to use it
1. Create your property of type `MutableCollectionProperty`

```swift
let property: MutableCollectionProperty<String> = MutableCollectionProperty(["test1", "test2"])
```

2. Use the property available subscribers:

```swift
property.producer.startWithNext { newCollection in
  // Do whatever you want with the new collection
  // e.g. tableView.reloadData()
}
property.changesProducer.startWithNext { change in
  switch change {
    case Remove(Int, T)
    case Insert(Int, T)
    case Composite([CollectionChange])
  }
}
```

## Developers
- If you had any problem, contact [pedro@gitdo.io](mailto://pedro@gitdo.io).
- You can also create an issue on the repository with your concern, problem, idea.
- If you want to contribute with the component remember to add tests that test your new feature.

## License

```
The MIT License (MIT)

Copyright (c) 2015 GitDo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
