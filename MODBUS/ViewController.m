//
//  ViewController.m
//  MODBUS
//
//  Created by admindyn on 2017/8/15.
//  Copyright © 2017年 admindyn. All rights reserved.
//
#import "ConstantsMODBUS2.h"
#import "modbus.h"
#import "ViewController.h"
#define BUG_REPORT(_cond, _format, _args ...) \
printf("\nLine %d: assertion error for '%s': " _format "\n", __LINE__, # _cond, ## _args)
#define ASSERT_TRUE(_cond, _format, __args...) {  \
if (_cond) {                                  \
printf("OK\n");                           \
} else {                                      \
BUG_REPORT(_cond, _format, ## __args);    \
goto close;                               \
}                                             \
};
@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*
     C++中允许在头文件中定义的有三中情况：
     
     （1）类定义
     
     （2）内联函数定义（inline函数。在头文件中有函数实现的，默认为内联函数）
     
     （3）const 对象定义
     */
    modbus_t *mbCtx;
    uint16_t tab_reg[32];
    //设置连接响应时间
    uint32_t old_response_to_sec;
    uint32_t old_response_to_usec;
    uint32_t new_response_to_sec;
    uint32_t new_response_to_usec;
    //设置传输数据大小
    int nb_points;
    int rc;
    //int use_backend; 枚举设置要启用的服务类型是RTU还是TCP
    //这里的register什么作用
    uint8_t *tab_rp_bits = NULL;
    uint16_t *tab_rp_registers = NULL;
    uint16_t *tab_rp_registers_bad = NULL;
   
    //
    int i;
    uint8_t value;
    /*服务器端和客户机 设置同一个IP地址 以手机连接MAC电脑的wifi网络 显示的mac电脑的路由地址为准*/
    mbCtx = modbus_new_tcp("192.168.201.1", 1502);
    modbus_set_debug(mbCtx, TRUE);
    modbus_set_error_recovery(mbCtx,
                              MODBUS_ERROR_RECOVERY_LINK |
                              MODBUS_ERROR_RECOVERY_PROTOCOL);
      modbus_get_response_timeout(mbCtx, &old_response_to_sec, &old_response_to_usec);
   int connectStatus= modbus_connect(mbCtx);
    if (connectStatus!=-1) {
        /* Read 5 registers from the address 0 */
      int registerStatus=  modbus_read_registers(mbCtx, 0, 5, tab_reg);
        if (registerStatus!=-1) {
            
            /* Allocate and initialize the memory to store the bits */
            nb_points = (UT_BITS_NB > UT_INPUT_BITS_NB) ? UT_BITS_NB : UT_INPUT_BITS_NB;
            tab_rp_bits = (uint8_t *) malloc(nb_points * sizeof(uint8_t));
            memset(tab_rp_bits, 0, nb_points * sizeof(uint8_t));
            
            
            /* Allocate and initialize the memory to store the registers */
            nb_points = (UT_REGISTERS_NB > UT_INPUT_REGISTERS_NB) ?
            UT_REGISTERS_NB : UT_INPUT_REGISTERS_NB;
            tab_rp_registers = (uint16_t *) malloc(nb_points * sizeof(uint16_t));
            memset(tab_rp_registers, 0, nb_points * sizeof(uint16_t));
            
            printf("\nTEST WRITE/READ:\n");
            
            rc = modbus_write_bit(mbCtx, UT_BITS_ADDRESS, ON);
            printf("1/2 modbus_write_bit: ");
//            ASSERT_TRUE(rc == 1, "");
            
            rc = modbus_read_bits(mbCtx, UT_BITS_ADDRESS, 1, tab_rp_bits);
            printf("2/2 modbus_read_bits: ");
//            ASSERT_TRUE(rc == 1, "FAILED (nb points %d)\n", rc);
//            ASSERT_TRUE(tab_rp_bits[0] == ON, "FAILED (%0X != %0X)\n",
//                        tab_rp_bits[0], ON);
            
            /* End single */
            
            /* Multiple bits */
            {
                uint8_t tab_value[UT_BITS_NB];
                
                modbus_set_bits_from_bytes(tab_value, 0, UT_BITS_NB, UT_BITS_TAB);
                rc = modbus_write_bits(mbCtx, UT_BITS_ADDRESS, UT_BITS_NB, tab_value);
                printf("1/2 modbus_write_bits: ");
//                ASSERT_TRUE(rc == UT_BITS_NB, "");
            }
            
            rc = modbus_read_bits(mbCtx, UT_BITS_ADDRESS, UT_BITS_NB, tab_rp_bits);
            printf("2/2 modbus_read_bits: ");
//            ASSERT_TRUE(rc == UT_BITS_NB, "FAILED (nb points %d)\n", rc);
            
             i = 0;
            nb_points = UT_BITS_NB;
            while (nb_points > 0) {
                int nb_bits = (nb_points > 8) ? 8 : nb_points;
                
               value = modbus_get_byte_from_bits(tab_rp_bits, i*8, nb_bits);
//                ASSERT_TRUE(value == UT_BITS_TAB[i], "FAILED (%0X != %0X)\n",
//                            value, UT_BITS_TAB[i]);
                
                nb_points -= nb_bits;
                i++;
            }
            printf("OK\n");
            /* End of multiple bits */
            
            /** DISCRETE INPUTS **/
            rc = modbus_read_input_bits(mbCtx, UT_INPUT_BITS_ADDRESS,
                                        UT_INPUT_BITS_NB, tab_rp_bits);
            printf("1/1 modbus_read_input_bits: ");
//            ASSERT_TRUE(rc == UT_INPUT_BITS_NB, "FAILED (nb points %d)\n", rc);
            
            i = 0;
            nb_points = UT_INPUT_BITS_NB;
            while (nb_points > 0) {
                int nb_bits = (nb_points > 8) ? 8 : nb_points;
                value = modbus_get_byte_from_bits(tab_rp_bits, i*8, nb_bits);
//                ASSERT_TRUE(value == UT_INPUT_BITS_TAB[i], "FAILED (%0X != %0X)\n",
//                            value, UT_INPUT_BITS_TAB[i]);
                
                nb_points -= nb_bits;
                i++;
            }
            printf("OK\n");

//            modbus_close(mbCtx);
//            modbus_free(mbCtx);
        }
    }else
    {
          fprintf(stderr, "Connection failed: %s\n", modbus_strerror(errno));
     modbus_free(mbCtx);
        modbus_get_response_timeout(mbCtx, &new_response_to_sec, &new_response_to_usec);
        
        printf("** UNIT TESTING **\n");
        
        printf("1/1 No response timeout modification on connect: ");
        
        
    }
    

    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
