require "Items/ProceduralDistributions"

local function addItem(distributionName, weight)
    local distribution = ProceduralDistributions.list[distributionName]
    if not distribution or not distribution.items then return end

    table.insert(distribution.items, "PoisonRelief.GastroCalmTablet")
    table.insert(distribution.items, weight)
end

addItem("MedicalClinicDrugs", 4.0)
addItem("MedicalStorageDrugs", 5.0)
addItem("BathroomCounter", 0.35)
