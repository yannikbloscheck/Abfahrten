import AppKit


extension NSTextField {
	open override var focusRingType: NSFocusRingType {
		get {
			return .none
		}
		
		set {
			// Do nothing
		}
	}
}
