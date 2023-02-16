classdef Simulation<handle
    properties
        CacheNum
        Caches
        IndexArray
        Cycle
    end
    methods
        function this = Simulation(config)
            %Cache Creation
            for i = 2:config{1}+1
                cacheObject = Cache(double(config{i}(1)), double(config{i}(2)), double(config{i}(3)), double(config{i}(4)), double(config{i}(5)));
                this.Caches = [this.Caches cacheObject];
            end
            
            %Declaration of Cycles and Number of Cache
            this.Cycle = 0;
            this.CacheNum=config{1};
        end

        %Runs Commands
        function run(this, op, tag, L2Index, L1Index, intrCycle, varargin)
            %Sets L2 Index
            L2Index = bin2dec([dec2bin(L2Index-1) dec2bin(L1Index-1)])+1;
            if (this.CacheNum>2)%If more than 2 caches
                extraIndexArray=zeros(this.CacheNum);
                extraIndexArray(1)=L1Index;
                extraIndexArray(2)=L2Index;
                for i=3:this.CacheNum
                    extraIndexArray(i)=bin2dec([dec2bin(varargin{1}(i-2)-1) dec2bin(extraIndexArray(i-1)-1)])+1;
                end
                this.IndexArray = extraIndexArray;
            else %Default 2 caches
                this.IndexArray = [L1Index L2Index]; 
            end

            %% READ OPTION
            if (op == 'r')
                for i = 1:this.CacheNum
                    %Cache Read
                    if i == 1 %L1 Cache
                        [res, evict, tagForEvicted, MissOrHit] = this.Caches(i).read(bin2dec([dec2bin(tag) dec2bin(L2Index-1)]), L1Index);
                    elseif i == 2 %L2 Cache
                        [res, evict, tagForEvicted, MissOrHit] = this.Caches(i).read(tag, L2Index);
                    else %L3+ Cache
                        [res, evict, tagForEvicted, MissOrHit] = this.Caches(i).write(tag, this.IndexArray(i));
                    end
    
                    %Cycle time
                    if intrCycle > this.Cycle
                        this.Cycle = intrCycle + this.Caches(i).Latency;
                        fprintf("%s L%d --Read-- Start:%d End:%d ", MissOrHit, i, intrCycle, this.Cycle)
                    else
                        fprintf("%s L%d --Read-- Start:%d End:%d ", MissOrHit, i, this.Cycle, this.Cycle + this.Caches(i).Latency)
                        this.Cycle = this.Cycle + this.Caches(i).Latency; 
                    end

                    %Check for eviction
                    if evict && this.Caches(i).WritePolicy == 1
                        if ~(i+1 > this.CacheNum)
                            eviction_cycles = this.evict(i+1,tagForEvicted);
                        end
                        fprintf("Eviction(%d) Start:%d End:%d \n", tag, this.Cycle,this.Cycle + eviction_cycles)
                        this.Cycle = this.Cycle + eviction_cycles;
                    end

                    %Stop Searching if Hit
                    if res == 1
                        fprintf("\n")
                        break;
                    end
                end
            
            elseif (op == 'w')
                %% Write OPTION
                for i = 1:this.CacheNum
                    if i == 1 %L1 Cache
                        [res, evict, tagForEvicted, MissOrHit] = this.Caches(i).write(bin2dec([dec2bin(tag) dec2bin(L2Index-1)]), L1Index);
                    elseif i == 2 %L2 Cache
                        [res, evict, tagForEvicted, MissOrHit] = this.Caches(i).write(tag, L2Index);
                    else %L3+ Cache
                        [res, evict, tagForEvicted, MissOrHit] = this.Caches(i).write(tag, this.IndexArray(i));
                    end
    
                    %Cycle time
                    if intrCycle > this.Cycle
                        fprintf("%s L%d --Write-- Start:%d End:%d \n", MissOrHit, i, this.Cycle, intrCycle + this.Caches(i).Latency)
                        this.Cycle = intrCycle + this.Caches(i).Latency;
                    else
                        fprintf("%s L%d --Write-- Start:%d End:%d \n", MissOrHit, i, this.Cycle, this.Cycle + this.Caches(i).Latency)
                        this.Cycle = this.Cycle + this.Caches(i).Latency;
                    end

                    %Check for eviction
                    if evict
                        if (i+1 > this.CacheNum)
                            eviction_cycles = 100;
                        else
                            eviction_cycles = this.evict(i+1,tagForEvicted);
                        end
                        
                        fprintf("Eviction(%d) Start:%d End:%d ", tag, this.Cycle,this.Cycle + eviction_cycles)
                        this.Cycle = this.Cycle + eviction_cycles;
                    end
                    
                    %Break out of loop if Hit (only for write-back+write-allocate)
                    if (res == 1 && this.Caches(i).WritePolicy == 1)
                        break;
                    end
                end 
            end
            fprintf("\n")
        end
        
        %% CARRY OUT EVICTION
        function [cycTime] = evict(this, cacheInd, tag)
            cycTime = 0;
            if cacheInd > this.CacheNum
                cycTime = cycTime + 100;
            else
                [~, evict, tagForEvicted, ~] = this.Caches(cacheInd).write(tag, this.IndexArray(cacheInd));
                if evict && cacheInd <= this.CacheNum
                    %Evict necessary block
                    cycTime = this.evict(cacheInd + 1, tagForEvicted);
                else
                    if cacheInd <= this.CacheNum
                        %Caches above L1
                        cycTime = cycTime + this.Caches(cacheInd).Latency;
                    else
                        %Main mem
                        cycTime = cycTime + 100;
                    end
                    
                end
                
            end
            
        end
        
        
    end
end

