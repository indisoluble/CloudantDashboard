# CloudantDashboard

This iOS app is able to manage multiple databases in a [Cloudant](https://cloudant.com/) account,
however it does not replicate yet all options available in the [Cloudant](https://cloudant.com/)
Dashboard.

The first time you launch the app, it will present an alertivew where you have to type your
[Cloudant](https://cloudant.com/) username and password. This information will be saved to the
Keychain so the next you will not have to introduce it again.

The app does not cache data, every action is asynchronously forwarded to the server using
[RestKit](https://github.com/RestKit/RestKit) and the UI is updated when the response arrives.

## Options available
* List all databases
* List documents (no paging)
* List all design docs in a database
* List documents in a design doc (no paging)
* Create a database
* Create a document
* Get a document
* Add a revision to a document
* Copy documents using a bulk operation
* Delete a database
* Delete a document

## License

See [LICENSE](LICENSE)

### Used libraries
* [RestKit](https://github.com/RestKit/RestKit), is under the Apache License 2.0.
* [JSONSyntaxHighlight](https://github.com/bahamas10/JSONSyntaxHighlight), is under the MIT License.
* [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore), is under the MIT License.
* [UIAlertView+Blocks](https://github.com/ryanmaxwell/UIAlertView-Blocks), is under the MIT License.
