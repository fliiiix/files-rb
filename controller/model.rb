# encoding: UTF-8
require "active_model/serializers"
require "mongo_mapper"
require "fileutils"
require "uri"

class UploadFile
  include MongoMapper::Document

  key :filePath,       String,  :require => true
  key :fileName,       String,  :require => true
  key :url,            String,  :require => true
  key :counter,        Integer, :numeric => true
  key :user,           String
  key :pass,           String
  timestamps!

  before_create :upload, :makeUrlNice

  private
  def upload
    #File upload
    filename = rand(36**8).to_s(36) + fileName
    path = File.expand_path(File.dirname(__FILE__) + "/../uploads/#{filename}")

    begin
      FileUtils.cp(filePath, path)
      self[:filePath] = path
    rescue Exception => e
      errors.add(:soundCloudUrl, "Ex: " + e.to_s)
    end
  end

  def makeUrlNice
    if url == nil
      errors.add(:url, "NO url for you!")
      return nil
    end
    turl = sanitize(url)
    counter = 0
    begin
      newUrl = turl + (counter != 0 ? "-#{counter}" : "")
      counter += 1
    end while UploadFile.first(:url => newUrl) != nil
    self[:url] = newUrl
  end

  def sanitize(string)
    string.downcase.gsub("ö", "oe").gsub("ü", "ue").gsub("ä", "ae").gsub(/\W/,'-').squeeze('-').chomp('-').sub!(/^-*/, '')
  end
end

class FailLogin
  include MongoMapper::Document
  key :ip,    String,  :require => true
  key :day,   Integer, :require => true
  key :month, Integer, :require => true
  key :year,  Integer, :require => true
end

class FailLoginViewModel
  attr_accessor :ip, :counter
  def initialize(ip, counter)
    @ip = ip
    @counter = counter
  end
end
