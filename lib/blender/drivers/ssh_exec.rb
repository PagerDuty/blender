module Blender::Driver::SSHExec
  def remote_exec(command, session)
    session.open_channel do |ch|
      ch.request_pty
      ch.exec(command) do |ch, success|
        unless success
          Log.debug("Command not found:#{success.inspect}")
          exit_status = -1
        end
        ch.on_data do |c, data|
          stdout << data
          c.send_data("#{password}\n") if data =~ /^blender sudo password: /
        end
        ch.on_extended_data do |c, type, data|
          stderr << data
        end
        ch.on_request "exit-status" do |ichannel, data|
          l = data.read_long
          exit_status = [exit_status, l].max
          Log.debug("exit_status:#{exit_status} , data:#{l}")
        end
      end
      Log.debug("Exit(#{exit_status}) Command: '#{command}'")
    end
  end
end
