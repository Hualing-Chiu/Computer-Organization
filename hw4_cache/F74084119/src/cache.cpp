#include <iostream>
#include <string>
#include <vector>
#include <math.h>
#include <fstream>
#include <cstdlib>
#include <ctime>
using namespace std;

int tag_length,index_length,offset_length;
unsigned int index,tag,offset;
void cache_cal(unsigned int mem,int block_size,int block_num,int set_num){ //cal memory tag,index,offset
	if(set_num!=1){
		index_length = log(set_num)/log(2);
	}else{
		index_length = 0;
	}
	
	offset_length = log(block_size)/log(2);

	tag_length = 32-index_length-offset_length;

	if(set_num != 1){
		index = mem << tag_length >> (tag_length+offset_length);
	}
	tag = mem>>(index_length + offset_length);
	//cout<<offset_length<<endl;
}

int main(int argc,char* argv[]){
	int cache_size,block_size,associative,replace,block_num,set_num,way;
	int finish,count=0,t=0;
	unsigned int address,temp,cache_tag;
	vector<unsigned int> memory;
	vector<unsigned int> cache;
	vector<int> FIFO_time;
	vector<int> LRU_time;
	vector<bool> valid;
	//vector<unsigned int> mem_tag;
	ifstream file_in;
	ofstream file_out;
	file_in.open(argv[1]);
	file_out.open(argv[2]);
	srand(time(NULL));
	if(!file_in){
		cout<<"error file!\n"; 
	}

	file_in>>cache_size>>block_size>>associative>>replace;
	
	while(file_in>>hex>>address){
		memory.push_back(address);
	}

	/*for(int i=0;i<129;i++){
		file_in>>hex>>address;
		memory.push_back(address);
	}*/
	//file_in>>hex>>address;
	//memory.push_back(address);
	
	block_num = pow(2,10)*cache_size/block_size;
	
	if(associative == 0){
		way = 1;
		set_num = block_num;
	}else if(associative == 1){
		way = 4;
		set_num = block_num/4;
	}else{
		way = block_num;
		set_num=1;
	}

	/*for(int i=0;i<memory.size();++i){
		cache_cal(memory.at(i),block_size,block_num,set_num);
		file_out<<hex<<index<<endl;
	}*/

	for(int i=0;i<block_num;i++){
		cache.push_back(0);
		valid.push_back(false);
		FIFO_time.push_back(0);
		LRU_time.push_back(0);	
	}

	for(int i=0;i<memory.size();i++){
		cache_cal(memory.at(i),block_size,block_num,set_num);
		++t;
		finish = 0;
		//hit
		for(int j=0;j<way;j++){
			//cache tag
			temp = cache.at(way*index+j);
			cache_tag = temp >> (offset_length+index_length);
			if(valid.at(way*index+j) == true && tag == cache_tag){
				//add_time.at(way*index+j) = time;
				LRU_time.at(way*index+j) = t;
				file_out<<"-1"<<endl;
				//count++;
				finish = 1;
				break;
			}
		}
		//cout<<"hit "<<count<<endl;
		//miss
		if(finish == 0){
			for(int j=0;j<way;j++){
				if(valid.at(way*index+j) == false){
					cache.erase(cache.begin()+way*index+j);
					cache.insert(cache.begin()+way*index+j,memory.at(i));
					valid.at(way*index+j) = true;
					FIFO_time.at(way*index+j) = t;
					LRU_time.at(way*index+j) = t;
					//cout<<"way*index+j "<<way*index+j<<endl;
					//cout<<"valid "<<valid.at(way*index+j)<<endl;
					file_out<<"-1"<<endl;
					//cout<<"miss"<<endl;
					finish = 1;
					break;						
				}
			}
		}
		//miss and replace
		int victim = way*index;
		if(finish == 0){
			switch(replace){
				case 0://FIFO
					for(int j=0;j<way;j++){
						if(FIFO_time.at(victim) > FIFO_time.at(way*index+j)){
							victim = way*index+j;					
						}
					}
					break;
				case 1://LRU
					for(int j=0;j<way;j++){
						if(LRU_time.at(victim) > LRU_time.at(way*index+j)){
							victim = way*index+j;
						}
					}
					break;	
				case 2://your policy
					victim = rand()%way + way*index;
					break;
				default: break;
			}
			int victim_tag = cache.at(victim) >> (offset_length+index_length);
			file_out<<victim_tag<<endl;
			cache.erase(cache.begin()+victim);
			cache.insert(cache.begin()+victim,memory.at(i));
			LRU_time.at(victim) = t;
			FIFO_time.at(victim) = t;
			finish = 1;
			//cout<<"miss and replace"<<endl;
		}
	}
	t = 0;
	file_in.close();
	file_out.close();
	return 0;
}
