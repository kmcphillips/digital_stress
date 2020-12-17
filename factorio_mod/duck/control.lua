script.on_event(defines.events.on_player_died,
  function(event)
    local player = game.get_player(event.player_index)
    local cause = event.cause

    local file_contents = player.name
    local file_name = "duck/on_player_died_" .. game.tick

    if cause.name == "locomotive" or cause.name == "fluid-wagon" or cause.name == "cargo-wagon" then
      game.write_file(file_name, file_contents, false) -- 0
      game.print("duck: 0 DAYS SINCE A TRAIN ACCIDENT")
    else
      game.print("duck: heat")
    end
  end
)
