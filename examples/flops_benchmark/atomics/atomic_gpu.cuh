/**
 * Abstract implementation of a DEVS atomic model.
 * Copyright (C) 2021  Román Cárdenas Rodríguez
 * ARSLab - Carleton University
 * GreenLSI - Polytechnic University of Madrid
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

	/**
	 * @brief DEVS atomic model.
	 *
	 * The Atomic class is closer to the DEVS formalism than the AtomicInterface class.
	 * @tparam S the data type used for representing a cell state.
	 */
    class AtomicGPU {
     public:
    	//double state;
    	double *x, *y, alpha, time, z, w, last_time, next_time;
    	size_t output_flops, transition_flops;
    	bool is_inbag_empty;
    	double in_bag[9];
    	double out_bag;
    	size_t num_messages_received;

    	__host__ __device__ AtomicGPU(){
    	}

    	__host__ __device__ AtomicGPU(size_t out_flops, size_t trans_flops){
    		next_time = 0;
    		last_time = 0;
    		z = 0.0;
    		w = 3.14;
    		alpha = 2.0;
    		is_inbag_empty = true;
    		output_flops = out_flops;
    		transition_flops = trans_flops;
    		for(size_t i = 0; i < 9; i++){
    			in_bag[i] = -1.0;
    		}
    		out_bag = -1.0;
    		num_messages_received = 0;
    	}

    	__host__ __device__ void initialize(size_t out_flops, size_t trans_flops){
    	    		next_time = 0;
    	    		last_time = 0;
    	    		z = 0.0;
    	    		w = 3.14;
    	    		alpha = 2.0;
    	    		is_inbag_empty = true;
    	    		output_flops = out_flops;
    	    		transition_flops = trans_flops;
    	    		for(size_t i = 0; i < 9; i++){
    	    			in_bag[i] = -1.0;
    	    		}
    	    		out_bag = -1.0;
    	    		num_messages_received = 0;
    	}


		/**
		 * Sends a new Job that needs to be processed via the Generator::outGenerated port.
		 * @param s reference to the current generator model state.
		 * @param y reference to the atomic model output port set.
		 */
		__host__ __device__ void output() {
			for(size_t i=0; i < output_flops; i++){
				z += w * alpha;
			}
			out_bag = z;
		}

		/**
		 * Updates GeneratorState::clock and GeneratorState::sigma and increments GeneratorState::jobCount by one.
		 * @param s reference to the current generator model state.
		 */
		__host__ __device__ void internal_transition() {
			for(size_t i=0; i < transition_flops; i++){
				z += w * alpha;
			}
		}

		/**
		 * Updates GeneratorState::clock and GeneratorState::sigma.
		 * If it receives a true message via the Generator::inStop port, it passivates and stops generating Job objects.
		 * @param s reference to the current generator model state.
		 * @param e time elapsed since the last state transition function was triggered.
		 * @param x reference to the atomic model input port set.
		 */
		__host__ __device__ void external_transition(double e) {
			for(size_t i=0; i < transition_flops; i++){
				z += w * alpha;
			}
		}

		/**
		 * Updates GeneratorState::clock and GeneratorState::sigma.
		 * If it receives a true message via the Generator::inStop port, it passivates and stops generating Job objects.
		 * @param s reference to the current generator model state.
		 * @param e time elapsed since the last state transition function was triggered.
		 * @param x reference to the atomic model input port set.
		 */
		__host__ __device__ void confluent_transition(double e) {
			for(size_t i=0; i < transition_flops; i++ ){
				z += w * alpha;
			}
		}

		/**
		 * It returns the value of GeneratorState::sigma.
		 * @param s reference to the current generator model state.
		 * @return the sigma value.
		 */
		__host__ __device__ double time_advance() {
			return 1;
		}

		/**
		* It returns the value of GeneratorState::sigma.
		* @param s reference to the current generator model state.
		* @return the sigma value.
		*/
		__host__ __device__ double get_next_time() {
			return next_time;
		}

		/**
		* It returns the value of GeneratorState::sigma.
		* @param s reference to the current generator model state.
		* @return the sigma value.
		*/
/*
		bool inbag_empty() {
			for(size_t i = 0; i < 9; i++){
				if(in_bag[i] != -1.0){
					is_inbag_empty == false;
				}
			}
			return is_inbag_empty;
		}
*/
		__host__ __device__ bool inbag_empty() {
			if(num_messages_received == 0){
				is_inbag_empty = true;
			} else {
				is_inbag_empty = false;
			}
			return is_inbag_empty;
		}

		/**
		* It returns the value of GeneratorState::sigma.
		* @param s reference to the current generator model state.
		* @return the sigma value.
		*/
		__host__ __device__ void insert_in_bag(double in_message) {
			in_bag[num_messages_received] = in_message;
			num_messages_received++;
		}

		/**
		* It returns the value of GeneratorState::sigma.
		* @param s reference to the current generator model state.
		* @return the sigma value.
		*/
		__host__ __device__ double get_out_bag() {
			return out_bag;
		}

		/************/
		__host__ __device__ void clear_bags() {
			for(size_t i = 0; i < 9; i++) {
				in_bag[i] = -1.0;
			}
			out_bag = -1.0;
			num_messages_received = 0;
		}

    };
