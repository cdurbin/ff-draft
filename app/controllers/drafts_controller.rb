class DraftsController < ApplicationController
  def create
    raise "Missing league id" if !params[:league_id]
    league = League.find_by id: params[:league_id]
    raise "Invalid league id" unless league
    draft = Draft.new(league_id: params[:league_id])
    draft.save!
    render text: draft.id
  end
end