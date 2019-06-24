

#if os(iOS)
import UIKit

public class HXImageView : UIImageView {
    
    var url:URL? {
        didSet {
            /*
            self.job = HXImageManager.shared.imageWithURL(url) {
                self.image = $0.image
            }
 */
        }
    }
    
    var job:HXImageJob?
    
}

#endif
