require "digest"
require "socket"

module PgTools
  class Status
    def self.ready?(host:, port:, user:, password: nil, database: nil)
      socket = TCPSocket.new(host, port)
      socket.write(build_startup_message(user: user, database: database))

      while true
        char_tag = socket.read(1)
        data = socket.read(4)
        length = data.unpack("L>").first - 4
        payload = socket.read(length)

        case char_tag
        when "E"
          # Received **ErrorResponse**
          break
        when "R"
          # Received **AuthenticationRequest** message
          decoded = payload.unpack("L>").first

          case decoded
          when 3
            # Cleartext password
            packet = [112, password.size + 5, password].pack("CL>Z*")
            socket.write(packet)
          when 5
            # MD5 password
            salt = payload[4..-1]
            hashed_pass = Digest::MD5.hexdigest([password, user].join)
            encoded_password = "md5" + Digest::MD5.hexdigest([hashed_pass, salt].join)
            socket.write([112, encoded_password.size + 5, encoded_password].pack("CL>Z*"))
          end
        when "Z"
          # Received **Ready for query** message
          return true
        end
      end

      false
    rescue Errno::ECONNREFUSED
      false
    end

    def self.build_startup_message(user:, database: nil)
      message = [0, 196608]
      message_size = 4 + 4
      pack_string = "L>L>"

      params = ["user", user]
      params.concat(["database", database]) if database

      params.each do |value|
        message << value
        message_size += value.size + 1
        pack_string << "Z*"
      end

      message << 0
      message_size += 1
      pack_string << "C"

      message[0] = message_size

      message.pack(pack_string)
    end
  end
end
