
<p align="left">
    <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" />
</p>


# iConnected

**iConnected** is an application intended to leverage abilities of
[*ConnectionChecker*](https://github.com/Andriikym/ConnectionChecker) - library with a goal to evaluate internet connection quality.

The application is written in Swift and designed to run on iOS 12+. For now it can perform evaluating of internet connection quality by:

* starting measuring in application directly;
* selecting home screen quick action;
* viewing the widget in Today View;
* using home screen quick action to show the widget;

## Intention

Sometimes we can get into a situation when iPhone indicators show that internet connection is present, but any attempt to open a webpage or use some service is failing. It can be justified by various reasons: long distance to or hanged router, hanged mobile carrier link or overloaded internet connection. It can be hundreds of them.

The very first step to fix such a situation is to clearly understand where is a root of the problem. The good idea is to check, is at really no internet on a device or desired webpage is just not responding for some local reasons.

Sending a few ping ([ICMP](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol)) messages to a stable server and measuring their round-trip time should help to determine connection state on a device.
That is what this application does.

## Usage

Clone this repository.  
Open the project. Dependencies should be updated automatically. (Update them manually if that did not happen).  
Use it as desired.

Hope it will be useful 😀
