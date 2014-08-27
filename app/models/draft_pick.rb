class DraftPick < ActiveRecord::Base
  attr_accessor :display_name

  def self.initialize_draft_picks(draft_id)
    draft = Draft.find_by id: draft_id
    league = League.find_by id: draft.league_id
    players = PlayerScore.where({scoring_settings_id: league.scoring_settings_id})
    players.push(*(Defense.all))
    players.push(*(Kicker.all))

    players.each do |player|
      pick = DraftPick.find_by({player_id: player.player_id, draft_id: draft.id}) ||
      DraftPick.new({
        player_id: player.player_id,
        draft_id: draft.id,
        pick_number: nil
        })
      pick.pick_number = nil
      pick.save!
    end
  end
  def self.filter_taken(players, draft_id)
    new_list = []
    players.each do |player|
      picked = DraftPick.find_by({player_id: player.player_id,
        draft_id: draft_id})
      new_list.push(player) unless picked && picked.pick_number
    end
    new_list
  end
end