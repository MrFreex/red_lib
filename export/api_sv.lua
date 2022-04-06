local addons = {}
local Utils = Common("Utils")

function Addon(name)
    return addons[name]
end


addons.Jobs = {}

local policeJobs = { "police", "sheriffP", "sheriffS" }

addons.Jobs.isPolice = function(job)
    return Utils.find(policeJobs, job)
end