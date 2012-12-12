    task priority_list_init;
        integer i;
//        reg [3:0] i;
    begin
        for( i=0 ; i<8 ; i=i+1 )
        begin
            irq_priority_list[i] = i[7:0];
        end
    end
    endtask

    task priority_list_rotate;
        input [2:0] idx_in;
        integer i;
//        integer idx;
//        reg [3:0] i;
        reg [2:0] idx;
    begin
        idx = idx_in;
        for( i=7 ; i>=0 ; i=i-1 )
        begin
            irq_priority_list[idx] = i[7:0];
            idx = idx - 3'b001;
        end
    end
    endtask

    task priority_queue_dump;
    begin
//        $display( "%d %d %d %d %d %d %d %d idx=%d", 
//            irq_priority_list[0], irq_priority_list[1], 
//            irq_priority_list[2], irq_priority_list[3], 
//            irq_priority_list[4], irq_priority_list[5], 
//            irq_priority_list[6], irq_priority_list[7],
//            irq_priority_idx );
    end
    endtask

    function [2:0] find_irq;
        input reg[7:0] irr;
        reg [7:0] i;
        reg [7:0] irq;
        reg [7:0] next_irq;
//        integer found;
//        reg [3:0] i;
//        reg [2:0] irq;
        reg found;
    begin
        /* I'm doing a linear search through the list to find an interrupt with
         * the highest priority. Not very efficient. I want to make it work
         * then make it work fast. This routine will also work for the
         * (forthcoming) user specified interrupt priority list.
         */
        irq = 0;
        found = 1'b0;

        for( i=0 ; i<8 ; i=i+1 )
        begin
            next_irq = irq;

            /* if this irq is pending */
            if( (8'h1<<i) & irr ) 
            begin
                
                //$display("find_irq i=%d 1<<i=%x irr=%x mask=%x", i, (4'h1<<i), irr, (1<<i)&irr );
                //$display("[i]=%x [irq]=%x", irq_priority_list[i], irq_priority_list[irq] );

                /* if we haven't found one yet, this will be the first entry we
                 * compare against the rest during the linear search
                 */
                if( found==1'b0 ) 
                begin
                    /* if this is the first entry we've found, don't compare
                     * priorities (need an "uninitialized" state)
                     */
                    found = 1'b1;
                    next_irq = i;
                    //$display( "found=",found );
                end
                else if( irq_priority_list[i] < irq_priority_list[irq] ) 
                begin
                    /* this priority is lower than the current so use it */
                    next_irq = i;
                end
                else 
                begin
                    next_irq = irq;
                end 
            end
            irq = next_irq;
        end
        //$display("find_irq irq=",irq);
        find_irq = irq[3:0];
    end
    endfunction


