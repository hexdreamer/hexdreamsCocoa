/*
 
Notes:
- Global, Class, Instance loggers
- logger inheritance in class and instances
- auto-nesting (if on same thread)
- remote control of logging on/off (or do we just log everything and filter?)
     - whether or not you log, send the logging point to the reader so the user can see it
     - browser on the reader to filter logs/set priorities
- dtrace? Can you even use dtrace from Swift?
 https://www.objc.io/issues/19-debugging/dtrace/
 https://www.bignerdranch.com/blog/hooked-on-dtrace-part-1/
- can remotely affect values that are logged by adjusting variables dictionary for Threads and Types with new keyPaths (only if keyPaths can be encoded somehow)
 
*/


@inlinable public func HXWarn(_ message:String) {
    print("HXWarn: \(message)")
}


// When your app should curl up into the fetal position and die, but you never want it to just quit.
@inlinable public func HXFetalError(_ message:String) {
    print("HXFetalError: \(message)")
}
