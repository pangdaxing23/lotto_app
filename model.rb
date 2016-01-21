require 'data_mapper'
require 'dm-sqlite-adapter'
require 'bcrypt'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, :key => true
  property :email, String, :length => 6..75
  property :username, String, :length => 3..50
  property :password, BCryptHash

  has n, :lotto_tickets

  def self.authenticate(params = {})
    return nil if params[:username].blank? or params[:password].blank?
    return nil unless @user = User.first(username: params[:username])
    return nil unless params[:username] == @user[:username]

    password_hash = Password.new(@user[:password])
    @user[:id] if password_hash == params[:password]
  end
end

class LottoTicket
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :num1, String
  property :num2, String
  property :num3, String
  property :num4, String
  property :num5, String
  property :num6, String
  property :created_at, DateTime, default: Time.now

  belongs_to :user
end

DataMapper.finalize
DataMapper.auto_upgrade!
