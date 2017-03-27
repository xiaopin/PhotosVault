# PhotosVault

[![Build](https://img.shields.io/wercker/ci/wercker/docs.svg)]()
[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)]()
[![License](https://img.shields.io/badge/license-MIT-orange.svg?style=flat)]()

一个管理私密相片的App

## Feature

- 支持Touch ID解锁应用
- 内置FTP服务器，可以通过FTP服务快速将图片从App拷贝到PC端

## Framework

- Photos.framework 访问系统相册/将图片存储到系统相册
- LocalAuthentication.framework 支持Touch ID快速解锁


## Requirements

- Xcode 8.1+
- iOS9.0+

## TODO

- 优化内存使用，目前是一次性加载完某个相册下的图片数据，这在大量图片的情况下将会导致内存占用率飙升，很可能会被系统kill掉，后期可以考虑采用分页加载以及其他手段进行优化
- 目前图片预览功能用的是系统的QuickLook.framework，底部的UIToolbar不支持功能扩展（不过就目前来说也足够使用），后期可以考虑采用其他第三方库

## 演示GIF

![GIF](./demo.gif)

## License

基于MIT License进行开源，详细内容请参阅`LICENSE`文件。
