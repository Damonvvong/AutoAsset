## AutoAsset
💻 A Swift Comment Line Tool For Automatically generate Asset Catalog

## Features

- [x] Automatically generate Asset Catalog
- [x] Supports incremental synchronization
- [x] Supports multiple folders

## Install

- **Download** the file for the latest release
    - [Go to the GitHub page for the latest release](https://github.com/Damonvvong/AutoAsset/releases)
    - Download the `AutoAsset` file associated with that release

- If you download the **AutoAsset** in a folder e.g. called _Script_ at the root of your project directory. You can then invoke **AutoAsset** in your Script Build Phase using:

```shell
"$PROJECT_DIR"/Script/AutoAsset …
```

## Usage

```shell
AutoAsset [FILE1] [FILE1_BACKUP] [FILE2]
```

`FILE1` Sync folder Path

`FILE1_BACKUP` Sync folder Backup Path

`FILE2` Asset Catalog Path


> The addition, deletion, and modification of the pictures in the `FILE1` by the designer are incrementally synchronized to `FILE2` when Xcode is compiled.

![autoassets](./autoassets.gif)

## Authors

* **Damonwong** - [Damonwong](https://github.com/Damonvvong)

## Communication

* If you **found a bug**, open an issue.
* If you **have a feature request**, open an issue.
* If you **want to contribute**, submit a pull request.

## License

This project is licensed under the MIT License.





