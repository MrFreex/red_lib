local Events = Common("Events")

Events.Register("sync_bag_fc", function(bag_identification, state_index, state_value)
    Events.TriggerClient("sync_bag", -1, { bag_identification, state_index, state_value }, "red_statebags")
    Events.Trigger("sync_bag", { bag_identification, state_index, state_value }, "red_statebags")
end, "red_statebags")

Events.Register("cleanState_fc", function(bag_identification)
    Events.TriggerClient("cleanState", -1, { bag_identification }, "red_statebags")
    Events.Trigger("sync_bag", { bag_identification }, "red_statebags")
end, "red_statebags")