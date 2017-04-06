//
//  ViewController.m
//  soundLEvelDemo
//
//  Created by Bogdan Laukhin on 4/6/17.
//  Copyright © 2017 ua.org. All rights reserved.
//

#import "ViewController.h"

#define volumeWarningText   @"Listening at a high volume for a long time may damage your hearing"


@interface ViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) NSArray *listOfMusicFiles;
@property (strong, nonatomic) AVAudioPlayer *musicPlayer;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@" %@", [NSNumber numberWithBool:self.isHearingDamageRisk]);
    
    NSArray *listOfAllFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"mp3" inDirectory:@"Music"];
    NSMutableArray *correctedNames = [[NSMutableArray alloc] init];
    for (NSString *path in listOfAllFiles) {
        NSString *theFileName = [[path lastPathComponent] stringByDeletingPathExtension];
        [correctedNames addObject:theFileName];
    }
    self.listOfMusicFiles = [NSArray arrayWithArray:correctedNames];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listOfMusicFiles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.textLabel.text = (self.listOfMusicFiles)[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.listOfMusicFiles[indexPath.row];
    
    [self playMusicWithTitle:title];
    
}


- (void)playMusicWithTitle:(NSString *)title {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:title ofType:@"mp3" inDirectory:@"Music"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    if (soundFilePath) {
        self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self.musicPlayer prepareToPlay];
        [self.musicPlayer play];
        
        [self.musicPlayer volume];
        if (self.isHearingDamageRisk) {
            float volume = self.musicPlayer.volume;
            if (volume > 0.4)
                [self showAlertWithMessage:volumeWarningText];
        }
        
    } else
        [self showAlertWithMessage:[NSString stringWithFormat:@"Sorry, can't find the %@ music track", title]];
}


- (void)volumeChanged:(NSNotification *)notification {
    if (self.isHearingDamageRisk) {
        float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        NSLog(@"%f", volume);
        if (volume > 0.4)
            [self showAlertWithMessage:volumeWarningText];
    }
}


- (IBAction)playButtonPressed:(id)sender {
    if (self.musicPlayer)
        [self.musicPlayer play];
    else
        [self playMusicWithTitle:(self.listOfMusicFiles)[0]];
}

- (IBAction)pauseButtonPressed:(id)sender {
    [self.musicPlayer pause];
}


- (IBAction)signoutButtonPressed:(id)sender {
    [self.musicPlayer stop];
    [_delegate userDidSignOutWithviewController:self];
}


- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0) {
    [super dismissViewControllerAnimated:flag completion:completion];
    self.delegate = nil;
}


- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:close];
    
    [self presentViewController:alert animated:YES completion:nil];
}




@end
