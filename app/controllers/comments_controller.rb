class CommentsController < ApplicationController
  before_action :set_commentable

  # POST /comments
  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html do
          flash["notice"] = 'Comment was successfully created.'
          redirect_back(fallback_location: @commentable)
        end
        format.json { render :show, status: :created, location: @comment }
      else
        format.html do
          flash["notice"] = 'Could not save your comment due to errers.'
          redirect_back(fallback_location: @commentable)
        end
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commentable
      @commentable = Band.find_by(id: params[:band_id]) || Comedian.find(params[:comedian_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:content)
    end
end
