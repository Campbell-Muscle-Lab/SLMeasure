---
title: Start new measurement
has_children: false
parent: Tutorial
nav_order: 1
---

# Start new measurement

This page provides simple instructions on how to perform a new sarcomere length measurement with SLMeasure.

## Instructions

+ Using the SLMeasure through the cloned repository
    - Launch MATLAB and double-click `SLMeasure.mlapp`. It is located under `<repo>` folder. 
    - The `SLMeasure.mlapp` file starts the MATLAB App Designer, then press <kbd>F5</kbd> to start the application.

After a few seconds, you should see a program window. Here is the SLMeasure interface (Clicking on any of the images on this page will open a larger version in a new browser window.).

The interface is divided into two different panels. Their functionality is summarized as follows:
+ Brightfield: This panel has multiple axes to show images and the intensity profiles. It is the initial processing before the calculation.
    + The image axes display the brightfield images. The images are loaded using the load image button above. The region of interest (ROI) box controls are placed above the image axes. **The microscope calibration is required to convert pixels to length scales (um/px in this case).**
    + The area enclosed by the ROI is displayed on the ROI axes.
    + Intensity profiles along the height of the ROI box are displayed on the Intensity Profiles axes. The intensity profile of the selected ROI row is highlighted.
    + The derivative of the selected trace is shown on the Derivative of the Intensity profile axes. The derivation is performed to remove systemic trends.

+ Sarcomere Length Calculation: This panel shows the outputs of proccessing the ROI with [Fast-Fourier Transform (FFT)](https://en.wikipedia.org/wiki/Fast_Fourier_transform) and [Autocorrelation Function (ACF)](https://en.wikipedia.org/wiki/Autocorrelation).
    + The resulting double-sided amplitude spectrum is given. The x-axis value of the first peak is highlighted on the axes. 
    + The autocorrelation of the derivate of the profile is shown on the ACF axes. A damped sine function is fitted to the ACF, and the wavelength of the damped sine function is highlighted.
    + Sarcomere length for each ROI row is shown in the Sarcomere Length Along ROI axes.
    + The median sarcomere length value for each ROI box for each method is tabulated.

<a href="media/start_up_window.png" target="_blank">![Load file button](media/start_up_window.png)</a>

The first step of the measurement with SLMeasure is to load an image file into the environment. The Load Image is located above the image axes, shown in red rectangle.

<a href="media/load_image.png" target="_blank">![Load image button](media/load_image.png)</a>

Upon clicking the Load Image button, it opens a normal Windows File Open Dialog. Locate the folder which has the brightfield images on your computer. SLMeasure can work with PNG (Portable Network Graphics) and TIFF or TIF (Tag Image File Format) files.

<a href="media/file_open.png" target="_blank">![File open](media/file_open.png)</a>

An image should now be displayed in the Brightfield panel (red rectangle). The loaded image is a permeabilized skeletal fiber. We expect to see a sarcomere length ranging from 2.5-2.7 um in this example.

<a href="media/image_loaded.png" target="_blank">![Image loaded](media/image_loaded.png)</a>

You can zoom into the area of interest using MATLAB's zoom-in controls. Change the cursor mode using the zoom-in controls, shown in the red rectangle. This feature appears on the top right corner of the image axes. It is hidden, but it appears as you hover over the image

<a href="media/zoom_buttons.png" target="_blank">![Zoom buttons](media/zoom_buttons.png)</a>

Conversion from pixels to micrometers(um) is crucial for the app's functionality. Edit the Microscope Calibration (um/px) field, shown in red rectangle.

<a href="media/microscope_calibration.png" target="_blank">![Zoom buttons](media/microscope_calibration.png)</a>

In this tutorial, the microscope calibration constant is 0.211 um/px. **Please note that the microscope calibration is unique to the experimental setup. Please use your experimental setup's calibration constant.**

The next step is to draw an ROI box for measurement. Box controls are placed above the brightfield image axes, shown in red rectangle.

<a href="media/new_box.png" target="_blank">![new box](media/new_box.png)</a>

After clicking the New Box button, the mouse cursor changes into a crosshair. Click on the image and expand the ROI to the desired size. You can always adjust the position of the ROI box by dragging it across the image. Make sure to place the box, where you can see "clear" striations. This is easy to accomplish using the skeletal preparation, whereas the cardiac preparations require a "closer" look. The newly generated box appears light green. The SLMeasure automatically processes the enclosed area in the ROI. Please note that all the empty axes and fields are populated now.

<a href="media/box_1.png" target="_blank">![box_1](media/box_1.png)</a>

You can visualize the processed traces and results from all the ROI boxes using the ROI row select spinner, shown in the red rectangle. The displayed trace belongs to the 7th row in the ROI box. The highlighted intensity trace and the resulting spectrum and ACF have the same color, burgundy.

<a href="media/change_row.png" target="_blank">![Change row](media/change_row.png)</a>

Measuring multiple regions over preparation and using the average sarcomere lengths is a good practice. Once you are completed with the current box, generate your next box as mentioned above. SLMeasure will automatically place a new box near the old box. All the boxes have the same dimensions. The new box becomes the selected box (light green), and the old box is shown in red. Drag the new box to the desired position. The new box is processed, and the new values are added to the table. You can change the selected box using the Box Selection dropdown, shown in the black rectangle.

<a href="media/box_2.png" target="_blank">![Box 2](media/box_2.png)</a>

Once you finish your measurement, click the File button on the toolbar (red rectangle) to save your measurement.

<a href="media/save_measurement.png" target="_blank">![Save measurement](media/save_measurement.png)</a>

The Save Measurement button opens the following file dialog box, which allows you to save SLMeasure measurement files in a unique .sl format. This file format can be loaded to SLMeasure to revisit the measurement. Name your file and click Save.

<a href="media/save_measurement_dialog.png" target="_blank">![Save measurement](media/save_measurement_dialog.png)</a>

Additionally, the sarcomere length table can be exported as an Excel file. Click the Export SL Table button. 

<a href="media/export_sl_table.png" target="_blank">![export sl table](media/export_sl_table.png)</a>

The button opens a file dialog box for the Excel file. Name your file and click Save.

<a href="media/sl_table_dialog.png" target="_blank">![Sl table dialog](media/sl_table_dialog.png)</a>

The exported Excel file has the same structure as the table.

<a href="media/sl_table_excel.png" target="_blank">![Sl table excel](media/sl_table_excel.png)</a>
