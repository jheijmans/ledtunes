require 'rubygems' 
require 'bundler/setup'  
require 'libusb'
# require 'itunes_observer'
load 'dcled_ruby.rb'

Dcled.new.message(`osascript CurrentTrack.scpt`)

# observer = ITunesObserver.new
# observer.on_play {|result|
#  puts '%s - %s' % [result['Artist'], result['Name']]
# }
# observer.run

# usb = LIBUSB::Context.new
# usb.devices(idVendor: 0x1d34, idProduct: 0x0013).each do |device|
#   
# end #(:idVendor => 0x1d34, :idProduct => 0x0013)
# # device.open_interface(0) do |handle|
# #   # handle.control_transfer(:bmRequestType => 0x40, :bRequest => 0xa0, :wValue => 0xe600, :wIndex => 0x0000, :dataOut => 1.chr)
# # end