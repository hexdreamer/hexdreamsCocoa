
public class CommandLineInterface {
    
    var specifications :[OptionSpecification]
    var options :[Option]
    var arguments :[String]

    public init() {
        self.specifications = [OptionSpecification]()
        self.options = [Option]()
        self.arguments = [String]()
        self.arg("h", "help", false, "Print this help")
    }
    
    public func arg(_ shortForm :String, _ longForm :String, _ hasValue :Bool, _ description :String) {
        self.specifications.append(OptionSpecification(shortForm, longForm, hasValue, description))
    }

    public func processCommandLine(_ cmdline :Array<String>) throws {
        var i = 1
        
        while true {
            let arg = cmdline[i]
            var remainder :String?
            
            i += 1
            
            remainder = arg.strippedOf(prefix:"--")
            if remainder == nil {
                remainder = arg.strippedOf(prefix:"-")
            }
            guard let optionarg = remainder else {
                self.arguments.append(arg)
                return
            }

            if let equalRange = optionarg.range(of:"=") {
                let optionName = optionarg[...equalRange.lowerBound]
                let optionValue = optionarg[equalRange.upperBound...]
                guard let specification = self.specificationFor(name:String(optionName)) else {
                    throw Errors.InvalidArgumentError("Unknown option \(optionName)")
                }
                if !specification.hasValue {
                    throw Errors.InvalidArgumentError("Option \(optionName) uses no value, but \(optionValue) was provided")
                }
                self.options.append(Option(specification:specification, value:String(optionValue)))
            } else {
                let optionName = optionarg
                var optionValue :String?
                guard let specification = self.specificationFor(name:optionName) else {
                    throw Errors.InvalidArgumentError("Unknown option \(optionName)")
                }
                if specification.hasValue {
                    if i + 1 >= cmdline.endIndex {
                        throw Errors.InvalidArgumentError("Option \(optionName) requires a value, but none was provided")
                    } else {
                        optionValue = cmdline[i]
                        i += 1
                    }
                }
                self.options.append(Option(specification:specification, value:optionValue))
            }
            
            if i >= cmdline.count {
                break
            }
        }
    }
    
    public func option(_ name :String) -> Bool {
        for option in self.options {
            let spec = option.specification
            if spec.shortName == name || spec.longName == name {
                return true
            }
        }
        return false
    }
    
    public func optionValue(_ name :String) -> String? {
        for option in self.options {
            let spec = option.specification
            if spec.shortName == name || spec.longName == name {
                return option.value
            }
        }
        return nil
    }
    
    func specificationFor(name :String) -> OptionSpecification? {
        for spec in self.specifications {
            if spec.shortName == name || spec.longName == name {
                return spec
            }
        }
        return nil
    }
    
    class OptionSpecification {
        let shortName   :String
        let longName    :String
        let hasValue    :Bool
        let description :String
        
        init(_ shortName :String, _ longName :String, _ hasValue :Bool, _ description :String) {
            self.shortName = shortName
            self.longName = longName
            self.hasValue = hasValue
            self.description = description
        }
    }
    
    class Option {
        let specification :OptionSpecification
        let value :String?
        
        init(specification :OptionSpecification, value :String?) {
            self.specification = specification;
            self.value = value
        }
    }

}

