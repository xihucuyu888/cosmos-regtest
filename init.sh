export GOPATH=/root/go
export PATH=$PATH:$GOPATH/bin

gaiacli tx send  validator0 cosmos1hrnl5pugag20gnu8zy3604jetqrjaf60czkl8u 5000000stake
sleep 5
gaiacli tx send validator0  cosmos10qjvlvn6x03ztc2uyt6tgfvah7wpy3zwyvz7gz 5000000stake
sleep 5
gaiacli tx send validator1  cosmos1880dqz6x8h0r2pxwy7nupypdrs07vk2md9322n 100000000stake
sleep 5
gaiacli tx send  validator1 cosmos1rml69htrp4ye4u6fuhyt9l3vdzuq0p00k8zhsl 100000000stake
