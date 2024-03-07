class DBEquivalenceTestStatus:
        Equiv = 1
        InEquiv = 2
        UnDetermined = 3
        Error = 4
class DBEquivalenceTestResult:  
        def __init__(self, result, extra_info=""):
            self.result = result
            self.extra_info = extra_info
            
class DBPerfTestStatus:
        Unknown = 0
        Success = 1
        Error = 2
        Timeout = 3
class DBPerfTestResult:
        def __init__(self, status:DBPerfTestStatus= DBPerfTestStatus.Unknown, runtime:float=-1, cost:float=-1, plan:str="", extra_info=""):
                self.status = status
                self.runtime = runtime
                self.cost = cost
                self.plan = plan
                self.extra_info = extra_info
