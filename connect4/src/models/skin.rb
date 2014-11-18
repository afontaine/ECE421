
module Models
  module Skin

    def self.img_path
      File.expand_path('../../../img', __FILE__)
    end

    def self.tokens
      [:O, :X, :T, :empty]
    end

    def self.default
      tokens.reduce({}) do |hsh, token|
        hsh[token] = File.join(img_path, get_img_name(token))
        hsh
      end
    end

    def self.get_img_name(token)
      token.to_s + '_token.png'
    end

  end
end