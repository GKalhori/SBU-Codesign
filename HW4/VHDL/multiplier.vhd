library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
library work;
use work.std_logic_arithext.all;


--datapath entity
entity multiplier is
port(
   x:in std_logic_vector(5 downto 0);
   y:in std_logic_vector(5 downto 0);
   start:in std_logic;
   result:out std_logic_vector(11 downto 0);
   done:out std_logic;
   RST : in std_logic;
   CLK : in std_logic

);
end multiplier;


--signal declaration
architecture RTL of multiplier is
signal M:std_logic_vector(5 downto 0);
signal M_wire:std_logic_vector(5 downto 0);
signal Q:std_logic_vector(5 downto 0);
signal Q_wire:std_logic_vector(5 downto 0);
signal product:std_logic_vector(5 downto 0);
signal product_wire:std_logic_vector(5 downto 0);
signal counter:std_logic_vector(2 downto 0);
signal counter_wire:std_logic_vector(2 downto 0);
signal sig_0:std_logic_vector(11 downto 0);
signal sig_1:std_logic_vector(5 downto 0);
signal sig_2:std_logic_vector(5 downto 0);
signal sig_3:std_logic_vector(4 downto 0);
signal sig_4:std_logic_vector(2 downto 0);
signal result_int:std_logic_vector(11 downto 0);
signal done_int:std_logic;
signal sig_5:std_logic;
type STATE_TYPE is (s0,s1,s2,s3,s4,s5);
signal STATE:STATE_TYPE;
type CONTROL is (alwaysIDLE
, alwaysinit
, alwaysdo_nothing
, alwaysadd
, alwaysshift
);
signal cmd : CONTROL;


begin
--register updates
dpREG: process (CLK,RST)
   begin
      if (RST = '1') then
         M <= (others=>'0');
         Q <= (others=>'0');
         product <= (others=>'0');
         counter <= (others=>'0');
      elsif CLK' event and CLK = '1' then
         M <= M_wire;
         Q <= Q_wire;
         product <= product_wire;
         counter <= counter_wire;

      end if;
   end process dpREG;


--combinational logics
dpCMB: process (M,Q,product,counter,sig_0,sig_1,sig_2,sig_3,sig_4,result_int
,done_int,x,y,start,cmd,STATE)
   begin
      M_wire <= M;
      Q_wire <= Q;
      product_wire <= product;
      counter_wire <= counter;
      sig_0 <= (others=>'0');
      sig_1 <= (others=>'0');
      sig_2 <= (others=>'0');
      sig_3 <= (others=>'0');
      sig_4 <= (others=>'0');
      result_int <= (others=>'0');
      done_int <= '0';
      result <= (others=>'0');
      done <= '0';



      case cmd is
         when alwaysIDLE =>
            sig_0 <= product & Q;
            result <= result_int;
            result_int <= sig_0;
            done <= done_int;
            done_int <= '1';
         when alwaysinit =>
            sig_0 <= product & Q;
            result <= result_int;
            result_int <= sig_0;
            done <= done_int;
            done_int <= '0';
            M_wire <= x;
            Q_wire <= y;
            product_wire <= conv_std_logic_vector(0,6);
            counter_wire <= conv_std_logic_vector(6,3);
         when alwaysdo_nothing =>
            sig_0 <= product & Q;
            result <= result_int;
            result_int <= sig_0;
            done <= done_int;
            done_int <= '0';
         when alwaysadd =>
            sig_0 <= product & Q;
            result <= result_int;
            result_int <= sig_0;
            sig_1 <= unsigned(M) + unsigned(product);
            done <= done_int;
            done_int <= '0';
            product_wire <= sig_1;
         when alwaysshift =>
            sig_0 <= product & Q;
            result <= result_int;
            result_int <= sig_0;
            sig_2 <= product(0) & Q(5 downto 1);
            sig_3 <= 0 & product(5 downto 1);
            sig_4 <= unsigned(counter) - unsigned(conv_std_logic_vector(1,3));
            done <= done_int;
            done_int <= '0';
            Q_wire <= sig_2;
            product_wire <= conv_std_logic_vector(unsigned(sig_3),6);
            counter_wire <= sig_4;
         when others=>
      end case;
   end process dpCMB;


--controller reg
fsmREG: process (CLK,RST)
   begin
      if (RST = '1') then
         STATE <= s0;
      elsif CLK' event and CLK = '1' then
         STATE <= STATE;
         case STATE is
            when s0 => 
                    STATE <= s1;
            when s1 => 
               if (start = '1') then
                       STATE <= s2;
               else
                       STATE <= s0;
               end if;
            when s2 => 
               if (Q(0) = '1') then
                       STATE <= s3;
               else
                       STATE <= s4;
               end if;
            when s3 => 
                    STATE <= s4;
            when s4 => 
               if (sig_5 = '1') then
                       STATE <= s0;
               else
                       STATE <= s2;
               end if;
            when s5 => 
            when others=>
         end case;
      end if;
   end process fsmREG;


--controller cmb
fsmCMB: process (M,Q,product,counter,sig_0,sig_1,sig_2,sig_3,sig_4,result_int
,done_int,sig_5,x,y,start,cmd,STATE)
   begin
   sig_5 <= '0';
   if (unsigned(counter) = 0) then
      sig_5 <= '1';
   else
      sig_5 <= '0';
   end if;
   cmd <= alwaysIDLE;
   case STATE is
      when s0 => 
              cmd <= alwaysIDLE;
      when s1 => 
         if (start = '1') then
                 cmd <= alwaysinit;
         else
                 cmd <= alwaysdo_nothing;
         end if;
      when s2 => 
         if (Q(0) = '1') then
                 cmd <= alwaysadd;
         else
                 cmd <= alwaysshift;
         end if;
      when s3 => 
              cmd <= alwaysshift;
      when s4 => 
         if (sig_5 = '1') then
                 cmd <= alwaysdo_nothing;
         else
                 cmd <= alwaysdo_nothing;
         end if;
      when s5 => 
      when others=>
      end case;
end process fsmCMB;
end RTL;
