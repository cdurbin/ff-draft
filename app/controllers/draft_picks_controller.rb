require 'pry'
class DraftPicksController < ApplicationController
  def create
    raise "Missing draft id" if !params[:draft_id]
    raise "Missing player id" if !params[:player_id]
    pick_number = DraftPick.where(draft_id: params[:draft_id].to_i).order("pick_number DESC").first.pick_number
    if pick_number
      pick_number = pick_number + 1
    else
      pick_number = 1
    end
    pick_number = params[:pick_number] if params[:pick_number]
      DraftPick.where(draft_id: params[:draft_id]).order("pick_number DESC").limit(1)
    pick = DraftPick.find_by({player_id: params[:player_id],
      draft_id: params[:draft_id]})
    pick.pick_number = pick_number
    pick.save!
    redirect_to player_scores_path(draft_id: params[:draft_id])
  end

  def undo_pick
    raise "Missing draft id" if !params[:draft_id]
    raise "Missing player id" if !params[:player_id]
    pick = DraftPick.find_by({player_id: params[:player_id],
      draft_id: params[:draft_id]})
    pick.pick_number = nil
    pick.save!
    redirect_to player_scores_path(draft_id: params[:draft_id])
  end
end