Mobile Applications for Public Health - Group 3

# Smart Apotheke

An app to conveniently pick a (German) medicament prescription, scan it, receive a list of scanned medicaments, order them to your home or specify a pharmacy to pick them up, and track medicament intake using a build-in calendar.

## Target system specifications

**Minimal Android SDK version**: 16 (Android 4.1)  
**Targeted Android SDK version**: 28 (Android 9.0)  
**Recommended hardware**: ~200 MB Storage, ~400 MB RAM  

## Development specifications

**Language**: Flutter 1.12.13+hotfix.5, Dart 2.7.0  
**IDE**: Visual Studio Code 1.41.1  

## Workflow

The following workflow diagram shows all (ui) widget interconnections that can be accessed by the user. The red arrow line shows a possible workflow for the main use-case, where the user tries to scan a medicament prescription, order and add it to the calendar.

<!-- use ![workflow.png](workflow.png) for dartdoc -->
![workflow.png](doc/api/workflow.png)

## Folder and code structure

Since there are no set best practices on how to organize the code, we decided to split our code into 3 folders:

**lib/data**: includes globally accessible storage data (e.g. list of recent medicaments)  
**lib/util**: includes interface logic to some back-end data from the Internet, I/O of the settings, helper classes and other utilities  
**lib/widgets**: includes all user interfaces, calls **lib/util** classes and accesses **lib/data**  

## Naming conventions

## Testing

- unit tests done

## Technical Documentation

The technical documentation was generated by Flutter's **dartdoc** tool, and is located under project's root folder at **doc/api/index.html**. Unfortunately, **dartdoc** was initially developed to generate technical API documentations and, therefore, only includes comments made for public classes, functions and fields. We didn't want to break any naming conventions, so we kept some classes, functions and fields private as that is considered best practice by Flutter's development team (https://flutter.dev/docs/development/ui/interactive#creating-a-stateful-widget). As stated in https://github.com/dart-lang/dartdoc/issues/664, Flutter's developers already consider to add a feature to include documentation for private instances in **dartdoc**.

## Task division

