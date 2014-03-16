# The MIT License (MIT)
# Copyright © 2013 Lewis Clayton
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'libusb'
load 'font.rb'

class Dcled
  PATH = File.expand_path(File.dirname(__FILE__))
  BRIGHTNESS = 3
  SPEED = 0.03 # delay between rows being pushed to the screen

  def message(input)
    @font = Font.new('fonts/transpo.yml')
    rescue_this { initialise }
    input.split('').each {|letter| @font.dcled_hash(letter).each_value {|v| to_screen( v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7] ) }}
    clear_screen
  end

  def rescue_this(&block)
    begin
      yield
    rescue LIBUSB::ERROR_ACCESS
      abort("No permission to access USB device! Try sudo.")
    rescue LIBUSB::ERROR_BUSY
      abort("The USB device is busy!")
    rescue NoMethodError
      abort("Could not find Dream Cheeky LED Message Board device!")
    end
  end

  def initialise
    usb = LIBUSB::Context.new
    device = usb.devices(:idVendor => 0x1d34, :idProduct => 0x0013).first
    @led = device.open
    if @led.kernel_driver_active?(0)
      @led.detach_kernel_driver(0)
    end
  end

  def format_packet(row, first_segment_row_1, second_segment_row_1, third_segment_row_1, first_segment_row_2, second_segment_row_2, third_segment_row_2 )
    bytes = Array.new(8)
    bytes[0] = BRIGHTNESS
    bytes[1] = row
    bytes[2] = third_segment_row_1.to_i(2)
    bytes[3] = second_segment_row_1.to_i(2)
    bytes[4] = first_segment_row_1.to_i(2)
    bytes[5] = third_segment_row_2.to_i(2)
    bytes[6] = second_segment_row_2.to_i(2)
    bytes[7] = first_segment_row_2.to_i(2)

    rescue_this { push_to_board(bytes) }
  end

  def push_to_board(bytes)
    @led.control_transfer(
      :bmRequestType => 0x21,
      :bRequest      => 0x09,
      :wValue        => 0x0000,
      :wIndex        => 0x0000,
      :dataOut       => bytes.pack('cccccccc')
    )
  end

  def clear_screen
    "    ".split('').each {|letter| @font.dcled_hash(letter).each_value {|v| to_screen( v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7] ) }}
  end

  def to_screen(row1_new, row2_new, row3_new, row4_new, row5_new, row6_new, row7_new, row8_new)
    @row1 ||= Array.new(24, 1)
    @row2 ||= Array.new(24, 1)
    @row3 ||= Array.new(24, 1)
    @row4 ||= Array.new(24, 1)
    @row5 ||= Array.new(24, 1)
    @row6 ||= Array.new(24, 1)
    @row7 ||= Array.new(24, 1)
    @row8 ||= Array.new(24, 1)

    8.times do |num|
      num += 1
      (eval "@row#{num}").unshift((eval "row#{num}_new"))
      (eval "@row#{num}").pop
    end

    format_packet(0, @row1.slice(16,8).join, @row1.slice(8,8).join, @row1.slice(0,8).join, @row2.slice(16,8).join, @row2.slice(8,8).join, @row2.slice(0,8).join)
    format_packet(2, @row3.slice(16,8).join, @row3.slice(8,8).join, @row3.slice(0,8).join, @row4.slice(16,8).join, @row4.slice(8,8).join, @row4.slice(0,8).join)
    format_packet(4, @row5.slice(16,8).join, @row5.slice(8,8).join, @row5.slice(0,8).join, @row6.slice(16,8).join, @row6.slice(8,8).join, @row6.slice(0,8).join)
    format_packet(6, @row7.slice(16,8).join, @row7.slice(8,8).join, @row7.slice(0,8).join, @row8.slice(16,8).join, @row8.slice(8,8).join, @row8.slice(0,8).join)

    sleep(SPEED)
  end



end