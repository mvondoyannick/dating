class ApiController < ActionController::API #ApplicationController
  before_action :user_account, except: [:signin, :signup]
  before_action :add_friend_verification_params, only: [:add_friend, :accept_friend_request]
    def signin
        if signup_params.present?
            @user = User.find_by(email: params[:email])
            if @user&.valid_password?(params[:password])
                render json: {
                    data: @user.as_json(only: [:name, :token, :email, :created_at, :sexe, :second_name, :color, :relationship, :gener, :job, :phone]),
                    friends: @user.friend.where(status: "accept").map do |friend|
                      {
                        id: friend.friend,
                        name: User.find(friend.friend).name.capitalize,
                        sexe: User.find(friend.friend).sex,
                        avatar: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(User.find(friend.friend).avatar, only_path: true)}",
                        added: User.find(friend.friend).created_at,
                        color: User.find(friend.friend).color,
                        relationship: User.find(friend.friend).relationship,
                        gender: User.find(friend.friend).gender,
                        job: User.find(friend.friend).job
                      }
                    end,
                    pending: @user.friend.where(status: "pending").map do |friend|
                      {
                        id: friend.friend,
                        name: User.find(friend.friend).name.capitalize,
                        sexe: User.find(friend.friend).sex,
                        avatar: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(User.find(friend.friend).avatar, only_path: true)}",
                        added: User.find(friend.friend).created_at,
                        color: User.find(friend.friend).color,
                        relationship: User.find(friend.friend).relationship,
                        gender: User.find(friend.friend).gender,
                        job: User.find(friend.friend).job
                      }
                    end
                }, status: :ok
            else
                render json: {
                    message: "Account or password not found or invalid",
                    errors: {
                        error_code: "X404",
                        error_description: "Account not found"
                    }
                }, status: 401
            end
        else
            render json: {
                message: "Missing parameters",
                errors: {
                    error_code: "X4OO",
                    error_description: "Not parameters"
                }
            }, status: 401
        end
    end

    def signup
      if signup_params.empty?
        render json: {
          message: "Missing parameters",
          errors: {
            error_code: "",
            error_description: ""
          }
        }, status: 401
      else
        @e_verification = EmailVerification::Verify.new(params[:email])
        @verified = @e_verification.go
        if @verified[0]
          @user = User.new(signup_params)
          @user.sex = Faker::Gender.binary_type
          @user.color = Faker::Color.color_name.capitalize
          @user.relationship = Faker::Relationship.spouse
          @user.gender = Faker::Gender.binary_type
          @user.job = Faker::Job.title
          @user.phone = Faker::PhoneNumber.cell_phone
          if @user.save
            render json: {
              message: "Account created"
            }, status: 201
          else
            render json: {
              message: "Unable to create account du an email error",
              errors: {
                error_code: "",
                error_description: @user.errors.messages
              }
            }, status: 401
          end
        else
          render json: {
            message: "Unable to verified email address #{params[:email]}",
            errors: {
              error_code: "",
              error_description: @verified[1]
            }
          }, status: 401
        end
      end
    end

    # create post API
    def add_post

    end

    # delete post
    def delete_post
    end

    # edit post
    def edit_post
    end

    # add friends to list
    def add_friend
      # check if this friend isnt't to our list friend
      if params[:user_id].to_i == params[:friend_id].to_i 
        render json: {
          message: "Not yourself"
        }, status: 400
      else
        @current_user = User.find(params[:user_id])
        if @current_user.friend.find_by(friend: params[:friend_id])
          render json: {
            message: "#{User.find(params[:user_id]).name} can't be added, You are friend with this user",
            errors: {
              error_code: "",
              error_description: ""
            }
          }, status: 401
        else
          # add friend
          puts "Starting adding friend ..."
          @new = @current_user.friend.new(friend: params[:friend_id], status: :pending)
          if @new.save
            render json: {
              message: "#{User.find(params[:user_id]).name} added as friend"
            }, status: 201
          else
            render json: {
              message: @new.errors.messages
            }, status: 401
          end
        end
      end

    end

    # def accept friend request
    def list_pending_friend_request
      @current_user = User.find(params[:user_id])
      render json: {
        pending_friend: @current_user.friend.where(status: :pending).map do |friend|
          {
            id: friend.friend,
            name: User.find(friend.friend).name,
            avatar: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(User.find(friend.friend).avatar, only_path: true)}",
            status: friend.status
          }
        end
      }, status: :ok
    end

    #
    def accept_friend_request
      @current_user = User.find(params[:user_id])
      @current_friend = User.find(params[:friend_id])

      if Friend.exists?(user_id: params[:user_id], friend: params[:friend_id], status: :accept) && Friend.exists?(user_id: params[:friend_id], friend: params[:user_id], status: :accept)

        render json: {
          message: "You are already friend with this user !"
        }, status: 401

      else

        # begin update
        if @current_user.friend.update(friend: params[:friend_id], status: :accept)

          # make request
          puts "Friend ID : #{params[:friend_id]}"
          @request = Friend.new(user_id: params[:user_id], friend: params[:friend_id], status: :accept)

          # save
          if @request.save

          render json: {
            message: "Request new friend accepted_by #{@current_user.name}, you can now talk with #{User.find(params[:user_id]).name}."
          }, status: :ok

          else

            render json: {
              message: "Linking to friends failled! #{@request.errors.messages}"
            }, status: 401

          end
        else
          render json: {
            message: "Unable to associate this friend"
          }, status: 401
        end

      end

    end

    # remove friend from list
    def remove_friend
    end

    # block friend from list
    def block_friend
    end

    #search friend
    def search_friend
    end

    # my friend list
    # return friend list object
    def my_friends
      @current_user = User.find(params[:user_id])
      render json: {
        friends: @current_user.friend.where(status: 'accept').map do |friend|
          {
            id: friend.id,
            name: User.find(friend.friend).name.upcase,
            avatar: "#{request.base_url}#{Rails.application.routes.url_helpers.rails_blob_path(User.find(friend.friend).avatar, only_path: true)}",
            date: friend.created_at
          }
        end
      }
    end

    private
    def signup_params
        params.permit(:name, :email, :password, :avatar)
    end

    # create post params
    def post_params
    end

    # def add friend params verification
    def add_friend_verification_params
      if User.exists?(id: params[:user_id]) && User.exists?(id: params[:friend_id])
        # good
      else

        render json: {
          message: "Unknow user or friend"
        }, status: 401

      end
    end

    # verify user
    def user_account
      if User.exists?(id: params[:user_id])
      else
        render json: {
          message: "Unknow user",
          errors: {
            error_code: "",
            error_description: ""
          }
        }, status: 401
      end
    end
end
