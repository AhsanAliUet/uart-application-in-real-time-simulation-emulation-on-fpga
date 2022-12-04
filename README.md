# Real time simulation of DUTs using UART
When we change some variable in our rtl to a new value, systhesis and implementation go out of date. Which them we have to do them again which is time consuming process. Xilinx Vivado users know this thing.  

We have come up with a thing that is very helpfull. You can change data of your design under test externally using UART. 

For example, you have made a counter which counts upto maximum decimal value 20. You have to change the value of maximum to 30, then if you do this, you synthesis and implementation goes out of date.  

To avoid this, just instantiate UART receiver in the design (in this case it is a counter). Receiver will receive data serially from computer/PC/Laptop/Microcontroller or any serial data sending device, and give this data to design and design will now operate on the new coming data.  

# Motivation
i. Another motivation is, if you run out of input switches on FPGA, you can give input to your FPGA using this scenario. I hope I was able to make you understand this project.  

ii. If we run out of input pins on FPGA, we can instantiate (keeping everything else same) receiver of uart in DUT (design under test). Receiver will receive data from PC/Laptop/Microcontroller serially and convert this serial data to parallel data and give it to DUT to use it without hesitation of shortage of input pins.  



A picture explaining this project is given below:

![counter_rx](https://user-images.githubusercontent.com/103721691/205504694-30ec4cdf-4030-48eb-8815-75a381b3058f.png)

SSD stands for seven segment displays. 

# Author
- [@Ahsan Ali](https://github.com/AhsanAliUet)




