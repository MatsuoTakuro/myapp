class User < ApplicationRecord
    # default: class_name to refer is "Micropost" (in /app/models/micropost.rb)
    # default: foreign key to refer is "user_id"
    has_many :microposts,           dependent:   :destroy

    has_many :active_relationships,     class_name:  "Relationship",
                                        foreign_key: "following_id",
                                        dependent:   :destroy
    has_many :passive_relationships,    class_name:  "Relationship",
                                        foreign_key: "followed_id",
                                        dependent:   :destroy
    # "@user.usersYouFollowing" is almost equal to "@user.active_relationships.map(&:followed)"
    has_many :usersYouFollowing,        through:     :active_relationships,
                                        source:      :followed
    # "@user.followers" is almost equal to "@user.passive_relationships.map(&:following)"
    has_many :followers,                through:     :passive_relationships,
                                        source:      :following

    attr_accessor   :remember_token,
                    :activation_token,
                    :reset_token
    # before_save   :downcase_email
    before_save { self.email = email.downcase }
    before_create :create_activation_digest
    validates :name,  presence: true, length: { maximum: 50 }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                        format: { with: VALID_EMAIL_REGEX },
                        uniqueness: true

    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

    # 渡された文字列のハッシュ値を返す
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    def remember
        self.remember_token = User.new_token
        self.update_attribute(:remember_digest, User.digest(remember_token))
    end

    # 渡されたトークンがダイジェストと一致したらtrueを返す
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # ユーザーのログイン情報を破棄する
    def forget
        update_attribute(:remember_digest, nil)
    end

    # アカウントを有効にする
    def activate
        update_columns( activated:    true,
                        activated_at: Time.zone.now)
    end

    # 有効化用のメールを送信する
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # パスワード再設定の属性を設定する
    def create_reset_digest
        self.reset_token = User.new_token
        update_columns( reset_digest:  User.digest(self.reset_token),
                        reset_sent_at: Time.zone.now)
    end

    # パスワード再設定のメールを送信する
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # パスワード再設定の期限が切れている場合はtrueを返す
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    # ユーザーのステータスフィードを返す
    def feed
        # ver.1 (2 queries)
        # Micropost.where("user_id IN (?) OR user_id = ?",
        #                                     self.usersYouFollowing_ids,
        #                                     self.id)

        # ver.2 (2 queries)
        # Micropost.where("user_id IN (:usersYouFollowing_ids)
        #                                 OR user_id = :user_id",
        #                                     usersYouFollowing_ids: self.usersYouFollowing_ids,
        #                                     user_id:               id)

        # ver.3 (1 query)
        # usersYouFollowing_ids = "SELECT followed_id FROM relationships WHERE following_id = :user_id"
        # Micropost.where("user_id IN (#{usersYouFollowing_ids})
        #                                 OR user_id = :user_id", user_id: id)

        # ver.4 (1 query, リスト 14.50:フィードをleft_outer_joinsで作る)
        part_of_feed = "relationships.following_id = :id or microposts.user_id = :id"
        Micropost.left_outer_joins(user: :followers)
                    .where(part_of_feed, { id: self.id }).distinct
                    .includes(:user, image_attachment: :blob)
    end

    # ユーザーをフォローする
    def follow(other_user)
        # relationship = self.active_relationships.new(followed_id: other_user.id)
        # relationship.save
        usersYouFollowing << other_user
    end

    # ユーザーをフォロー解除する
    def unfollow(other_user)
        active_relationships.find_by(followed_id: other_user.id).destroy
    end

    # 現在のユーザーがフォローしてたらtrueを返す
    def following?(other_user)
        usersYouFollowing.include?(other_user)
    end

    private
        # # メールアドレスをすべて小文字にする
        # def downcase_email
        #     self.email = email.downcase
        # end

        # 有効化トークンとダイジェストを作成および代入する
        def create_activation_digest
            self.activation_token  = User.new_token
            self.activation_digest = User.digest(activation_token)
        end
end
