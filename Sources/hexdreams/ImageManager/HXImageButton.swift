
#if os(OSX)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

#if os(OSX)
    public class HXImageButton : NSButton {
        
    }
#elseif os(iOS)
    public class HXImageButton : UIButton {
        
    }
#endif


