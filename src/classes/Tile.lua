Tile = class("Tile")
function Tile:initialize (blocked, block_sight)
    self.blocked = blocked
    self.block_sight = block_sight or blocked
    self.visibility = special_colors.fov_blocked
end