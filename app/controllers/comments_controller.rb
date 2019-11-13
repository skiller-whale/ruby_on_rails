class CommentsController < ApplicationController
  before_action :set_band

  # POST /comments
  def create
    @comment = @band.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html do
          flash["notice"] = 'Comment was successfully created.'
          redirect_back(fallback_location: @band)
        end
        format.json { render :show, status: :created, location: @comment }
      else
        format.html do
          flash["notice"] = 'Could not save your comment due to errers.'
          redirect_back(fallback_location: @band)
        end
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_band
      @band = Band.find(params[:band_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:content)
    end
end
