# Schrodinger

An extremely simple promise library.

## Usage

Run code asynchronously and await their results.
Supports error throwing.

```swift
let promisedResult = async {
	// Run your heavy code
	throw An.error
	
 	return successfulResults
}

try promise.await()
```

Set custom timeouts.

```swift
async(
```