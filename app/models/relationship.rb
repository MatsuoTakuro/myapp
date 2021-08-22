class Relationship < ApplicationRecord
    # If you define association_name only, sql query(CRUD) from {association_name}s table, where {association_name}_id = {association_name}_id.
    # => for example,                      sql query(CRUD) from followers           table, where follower_id           = follower_id.
    # If you expressly define class_name,  sql query(CRUD) from {class_name}s       table, where {class_name}_id       = {association_name}_id.
    # => for example,                      sql query(CRUD) from users               table, where user_id               = follower_id.
    # Because the foreign key of relationship model is not "user_id"(=class_name's id), but "follower_id"(=association_name's id).
    belongs_to :follower, class_name: "User"
    belongs_to :followed, class_name: "User"

    validates :follower_id, presence: true
    validates :followed_id, presence: true
end
