local Events = Common("Events")

Events.Register("sync_bag_fc", function(bag_identification, state_index, state_value)
    Events.TriggerClient("sync_bag", -1, { bag_identification, state_index, state_value }, "red_statebags")
end, "red_statebags")