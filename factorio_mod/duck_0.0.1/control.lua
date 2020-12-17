script.on_event(defines.events.on_player_died,
  function(event)
    local player = game.get_player(event.player_index)
    local cause = event.cause

    if cause.name == "locomotive" then
      game.write_file("duck/on_player_died_" .. game.tick, player.name, false, 0)
      game.print("0 DAYS SINCE A TRAIN ACCIDENT")
    end
  end
)
