local Events = Common("Events")

Events.Register("sync_bag_fc", function(bag_identification, state_index, state_value, old_value)
    Events.TriggerClient("sync_bag", -1, { bag_identification, state_index, state_value, old_value }, "red_statebags")
    Events.Trigger("sync_bag", { bag_identification, state_index, state_value, old_value }, "red_statebags")
end, "red_statebags")

Events.Register("cleanState_fc", function(bag_identification)
    Events.TriggerClient("cleanState", -1, { bag_identification }, "red_statebags")
    Events.Trigger("cleanState", { bag_identification }, "red_statebags")
end, "red_statebags")

Events.Register("sync_all", function(res)
    print("Sync all to", source, res)
    Events.TriggerClient("sync_all", source, { BagsList }, res)
end, "red_statebags")